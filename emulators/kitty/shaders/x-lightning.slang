#language slang 2026
// X Lightning: a jagged, electric cursor trail for kitty >= 0.49.
// The cursor leaves a short-lived bolt with forks, afterglow and sparks.
// Independent implementation inspired by the idea of a lightning cursor trail.

import kitty_custom_shader_types;

// ---- Tuning (override with var in x-trail.pipeline) ----
static const float BOLT_DURATION = 0.16;
static const float BOLT_CORE_WIDTH = 1.0;
static const float BOLT_GLOW_WIDTH = 5.0;
static const float BOLT_JAGGEDNESS = 0.11;
static const int BOLT_SEGMENTS = 12;
static const int FORK_COUNT = 4;
static const float BOLT_INTENSITY = 0.65;
static const float AFTERGLOW = 0.22;
static const float FLICKER = 0.04;

// Ignore tiny moves (e.g. single-cell typing) and cap long jumps so the bolt
// stays near the cursor instead of crossing the whole terminal.
static const float MIN_MOVE_PX = 0.0;
static const float MAX_BOLT_LENGTH = 280.0;

static const float SPARK_OPACITY = 0.55;
static const int MAX_SPARKS = 18;
static const float SPARK_LIFETIME = 0.18;
static const float SPARK_EMIT = 0.06;
static const float SPARK_SPEED = 18.0;
static const float SPARK_SPREAD = 1.0;
static const float SPARK_SIZE = 0.09;
static const float SPARK_DRAG = 2.2;

static const float3 BOLT_CORE_COLOR = float3(0.75, 0.92, 1.0);
static const float3 BOLT_GLOW_COLOR = float3(0.25, 0.50, 1.0);
static const float3 BOLT_ACCENT_COLOR = float3(0.55, 0.35, 1.0);
static const float3 SPARK_COLOR = float3(0.70, 0.90, 1.0);

static const float PI = 3.14159265359;

static float
hash11(float p) {
    p = frac(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

static float
hash21(float2 p) {
    float3 p3 = frac(float3(p.x, p.y, p.x) * 0.1031);
    p3 += dot(p3, float3(p3.y, p3.z, p3.x) + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}

static float
segment_dist(float2 p, float2 a, float2 b) {
    float2 ab = b - a;
    float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0);
    return length(p - (a + ab * t));
}

static float2
bolt_point(float2 a, float2 b, float t, float seed) {
    float2 delta = b - a;
    float bolt_len = max(length(delta), 1e-5);
    float2 perp = float2(-delta.y, delta.x) / bolt_len;
    float node = floor(t * float(BOLT_SEGMENTS) + 0.5);
    float rnd = hash11(node * 17.17 + seed) * 2.0 - 1.0;
    float fade = sin(PI * clamp(t, 0.0, 1.0));
    return lerp(a, b, t) + perp * rnd * bolt_len * BOLT_JAGGEDNESS * fade;
}

static float
bolt_dist(float2 p, float2 a, float2 b, float seed) {
    float min_d = 1e5;
    float2 prev = a;
    [ForceUnroll]
    for (int i = 1; i <= BOLT_SEGMENTS; i++) {
        float t = float(i) / float(BOLT_SEGMENTS);
        float2 cur = bolt_point(a, b, t, seed);
        min_d = min(min_d, segment_dist(p, prev, cur));
        prev = cur;
    }
    return min_d;
}

static float
fork_dist(float2 p, float2 a, float2 b, float seed) {
    float min_d = 1e5;
    float2 delta = b - a;
    float bolt_len = max(length(delta), 1e-5);
    float2 perp = float2(-delta.y, delta.x) / bolt_len;
    float2 dir = normalize(delta);

    [ForceUnroll]
    for (int i = 0; i < FORK_COUNT; i++) {
        float fi = float(i);
        float t = 0.24 + fi * 0.16;
        float2 root = bolt_point(a, b, t, seed);
        float side = lerp(-1.0, 1.0, step(0.5, hash11(seed + fi * 41.0)));
        float reach = bolt_len * (0.05 + 0.05 * hash11(seed + fi * 53.0));
        float2 along = dir * reach * (hash11(seed + fi * 67.0) - 0.30);
        float2 tip = root + perp * side * reach + along;
        float2 elbow = lerp(root, tip, 0.52)
            - perp * side * reach * (0.12 + 0.18 * hash11(seed + fi * 79.0));
        min_d = min(min_d, segment_dist(p, root, elbow));
        min_d = min(min_d, segment_dist(p, elbow, tip));
    }
    return min_d;
}

// Center (xy) and size (zw) in pixels of a cursor rectangle given in UV edges.
static float4
rect_center_size(float4 edges, float2 pixel_dims) {
    float2 lo = float2(edges.x, edges.w) * pixel_dims;
    float2 hi = float2(edges.y, edges.z) * pixel_dims;
    return float4((lo + hi) * 0.5, hi - lo);
}

static bool
valid_rect(float4 edges) {
    return edges.y > edges.x && edges.z > edges.w;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    if (d.cursor_trail_change_time <= 0.0) return color;
    if (!valid_rect(d.cursor_trail_edge)) return color;

    float age = max(0.0, d.timestamp - d.cursor_trail_change_time);
    if (age >= BOLT_DURATION + SPARK_LIFETIME) return color;

    float2 pixel_dims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 px = t.pos * pixel_dims;

    float4 cur = rect_center_size(d.cursor_trail_edge, pixel_dims);
    float4 prev = rect_center_size(d.cursor_trail_prev_edge, pixel_dims);
    float2 a = cur.xy;
    float2 b = cur.xy;
    if (valid_rect(d.cursor_trail_prev_edge)) {
        a = prev.xy;
        b = cur.xy;
    } else {
        // First move after the trail starts: draw a short bolt above the cursor.
        a = b - float2(0.0, max(cur.w, 1.0) * 1.5);
    }

    float2 delta = b - a;
    float bolt_len = length(delta);
    if (bolt_len < max(MIN_MOVE_PX, 0.5)) return color;
    if (bolt_len > MAX_BOLT_LENGTH) {
        a = b - (delta / bolt_len) * MAX_BOLT_LENGTH;
        delta = b - a;
        bolt_len = MAX_BOLT_LENGTH;
    }
    float2 perp = float2(-delta.y, delta.x) / bolt_len;
    float2 dir = delta / bolt_len;

    float seed = floor(d.cursor_trail_change_time * 1000.0) * 0.013;
    float3 trail_rgb = d.cursor_trail_color.a > 0.0
        ? d.cursor_trail_color.rgb
        : d.cursor_color.rgb;
    float3 glow_rgb = lerp(BOLT_GLOW_COLOR, trail_rgb, 0.35);

    float d_main = bolt_dist(px, a, b, seed);
    float d_side = bolt_dist(px, a + perp * 3.0, b + perp * 2.0, seed + 13.0);
    float d_fork = fork_dist(px, a, b, seed);

    float aa = max(fwidth(d_main), 0.65);
    float core = 1.0 - smoothstep(BOLT_CORE_WIDTH, BOLT_CORE_WIDTH + aa, d_main);
    float side_core = 1.0 - smoothstep(BOLT_CORE_WIDTH * 0.55,
                                       BOLT_CORE_WIDTH * 0.55 + aa, d_side);
    float fork_core = 1.0 - smoothstep(BOLT_CORE_WIDTH * 0.70,
                                       BOLT_CORE_WIDTH * 0.70 + aa, d_fork);

    float glow = exp(-d_main * d_main / (BOLT_GLOW_WIDTH * BOLT_GLOW_WIDTH));
    float side_glow = exp(-d_side * d_side / (BOLT_GLOW_WIDTH * BOLT_GLOW_WIDTH * 0.55));
    float fork_glow = exp(-d_fork * d_fork / (BOLT_GLOW_WIDTH * BOLT_GLOW_WIDTH * 0.55));

    float flash = max(0.0, 1.0 - age / BOLT_DURATION);
    flash *= flash;
    flash *= 1.0 - FLICKER + FLICKER * sin(age * 90.0 + seed);
    // Short moves (typing) keep a small, dimmer pulse; long jumps get the full bolt.
    flash *= 0.45 + 0.55 * smoothstep(4.0, 48.0, bolt_len);

    // Keep the afterglow attached to the bolt instead of tinting the whole terminal.
    float after = exp(-age * 9.0) * AFTERGLOW * 0.35 *
        exp(-d_main * d_main / (BOLT_GLOW_WIDTH * BOLT_GLOW_WIDTH * 4.0));

    float core_amt = max(max(core, side_core * 0.50), fork_core * 0.70);
    float glow_amt = max(max(glow, side_glow * 0.40), fork_glow * 0.40);

    // Compact electric pulse at the cursor for short (typing) moves.
    float d_cur = length(px - cur.xy);
    float small_gain = 1.0 - smoothstep(6.0, 24.0, bolt_len);
    float cursor_glow = exp(-d_cur * d_cur /
        (BOLT_GLOW_WIDTH * BOLT_GLOW_WIDTH * 1.6)) * small_gain *
        flash * BOLT_INTENSITY * 0.55;
    glow_amt = max(glow_amt, cursor_glow);
    core_amt = max(core_amt, cursor_glow * 0.30);

    core_amt = saturate(core_amt * flash * BOLT_INTENSITY);
    glow_amt = saturate(glow_amt * flash * BOLT_INTENSITY);
    float accent = saturate(exp(-d_main * d_main /
        (BOLT_GLOW_WIDTH * BOLT_GLOW_WIDTH * 3.5)) * flash * 0.30);

    float3 lit = lerp(color.rgb, glow_rgb, clamp(glow_amt + after, 0.0, 0.85));
    lit = lerp(lit, BOLT_CORE_COLOR, core_amt);
    lit = lerp(lit, BOLT_ACCENT_COLOR, clamp(accent * 0.45, 0.0, 0.45));

    // Sparks fly off the bolt while it is alive.
    if (age < SPARK_LIFETIME + SPARK_EMIT) {
        float spark_scale = max(cur.w, 1.0);
        float3 sparks = float3(0.0);
        [ForceUnroll]
        for (int i = 0; i < MAX_SPARKS; i++) {
            float fi = float(i);
            float r1 = hash11(fi * 0.618 + seed + 4.1);
            float r2 = hash11(fi * 1.117 + seed + 11.3);
            float r3 = hash11(fi * 2.317 + seed + 27.1);
            float u = (fi + r1) / float(MAX_SPARKS);
            float t = age - u * SPARK_EMIT;
            if (t < 0.0 || t >= SPARK_LIFETIME) continue;

            float2 spawn = lerp(a, b, u) + perp * (r2 * 2.0 - 1.0) * spark_scale * 0.8;
            float2 vel = perp * (r3 * 2.0 - 1.0) * SPARK_SPREAD
                + dir * (0.25 + 0.75 * r2) * 0.45;
            vel = normalize(vel + float2(1e-5, 1e-5));
            float travel = SPARK_SPEED * spark_scale *
                (1.0 - exp(-SPARK_DRAG * t)) / SPARK_DRAG;
            float life = 1.0 - t / SPARK_LIFETIME;
            float radius = max(SPARK_SIZE * spark_scale * lerp(0.4, 1.0, life), 0.6);
            float disc = saturate(radius + 0.5 - length(px - (spawn + vel * travel)));
            sparks = max(sparks, SPARK_COLOR * disc * life);
        }
        lit += sparks * (SPARK_OPACITY * flash);
    }

    // Keep the cursor itself crisp on top of the effect.
    float inside = step(d.cursor_trail_edge.x, t.pos.x) * step(t.pos.x, d.cursor_trail_edge.y) *
                   step(d.cursor_trail_edge.w, t.pos.y) * step(t.pos.y, d.cursor_trail_edge.z);
    lit = lerp(lit, color.rgb, inside);
    return float4(lit, color.a);
}
