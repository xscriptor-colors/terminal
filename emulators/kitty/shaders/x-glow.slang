#language slang 2026
// Xscriptor neon trail: a brighter afterglow with sparks for the cursor
// trail, meant to run after cursor-trail-default from x-trail.pipeline.
//
// When typing, every keypress leaves a bright core with a soft halo that
// decays for a fraction of a second; when jumping between lines the move is
// longer, so the beam stretches and more sparks fly off it.
//
// Requires kitty >= 0.49.0 and the shader-slang compiler (`slangc`).
// Every static const below can be overridden from the pipeline with `var`.

import kitty_custom_shader_types;

// Maximum blend of the glow color over the content, from 0 to 1.
static const float GLOW_STRENGTH = 0.9;
// How many seconds the afterglow takes to fade out.
static const float GLOW_DURATION = 0.7;
// Beam half-width, as a fraction of the cursor size.
static const float CORE_WIDTH = 0.12;
// Halo radius, as a fraction of the cursor size.
static const float HALO_SCALE = 1.1;
// Extra flash at the leading edge of every move, from 0 to 1.
static const float HEAD_FLASH = 0.95;
// Spark brightness, from 0 to 1.
static const float SPARK_OPACITY = 1.0;
// Maximum number of sparks for every cursor move.
static const int MAX_SPARKS = 56;
// How many sparks to emit for every line height of distance travelled.
static const float SPARK_DENSITY = 3.5;
// How long sparks live, in seconds.
static const float SPARK_LIFETIME = 0.7;
// Sparks are emitted in sequence while the cursor travels, taking this many
// seconds, so a fast jump draws a trail of sparks behind it.
static const float SPARK_EMIT = 0.09;
// Spark radius, as a fraction of the cursor size.
static const float SPARK_SIZE = 0.11;
// How fast sparks fly, in cursor sizes per second.
static const float SPARK_SPEED = 26.0;
// How widely sparks fan out to the sides of the movement direction.
static const float SPARK_SPREAD = 1.0;
// How fast sparks slow down. Larger values stop them sooner.
static const float SPARK_DRAG = 2.0;
// Color of the glow and sparks. When the alpha is zero the cursor trail
// color is used.
static const float4 GLOW_COLOR = float4(0.0);

// Classic GPU hash, returns a pseudo-random value in [0, 1).
static float
hash11(float p) {
    return frac(sin(p * 12.9898 + 78.233) * 43758.5453);
}

// Shortest distance from p to the segment a-b, in pixels.
static float
segment_distance(float2 p, float2 a, float2 b) {
    float2 ab = b - a;
    float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 1e-6), 0.0, 1.0);
    return length(p - (a + ab * t));
}

// Center (xy) and size (zw) in pixels of a cursor rectangle given in UV edges.
static float4
rect_center_size(float4 edges, float2 pixel_dims) {
    float2 lo = float2(edges.x, edges.w) * pixel_dims;
    float2 hi = float2(edges.y, edges.z) * pixel_dims;
    return float4((lo + hi) * 0.5, hi - lo);
}

// True when the rectangle given in UV edges is not empty.
static bool
valid_rect(float4 edges) {
    return edges.y > edges.x && edges.z > edges.w;
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    if (!valid_rect(d.cursor_trail_edge) || d.cursor_trail_change_time <= 0.0) return color;

    float age = max(0.0, d.timestamp - d.cursor_trail_change_time);
    if (age >= GLOW_DURATION + SPARK_LIFETIME + SPARK_EMIT) return color;

    float2 pixel_dims = float2(d.viewport_size_pixels) * t.viewport.zw;
    float2 px = t.pos * pixel_dims;
    float3 glow_rgb = GLOW_COLOR.a > 0.0 ? GLOW_COLOR.rgb : (d.cursor_trail_color.a > 0.0 ? d.cursor_trail_color.rgb : d.cursor_color.rgb);

    float4 cur = rect_center_size(d.cursor_trail_edge, pixel_dims);
    float2 cur_c = cur.xy;
    float scale = max(max(cur.z, cur.w), 1.0);
    float radius2 = HALO_SCALE * scale * HALO_SCALE * scale + 1e-6;

    float fade = max(0.0, 1.0 - age / GLOW_DURATION);
    fade *= fade;

    // Flash right at the cursor, always visible even on the first move.
    float glow = exp(-dot(px - cur_c, px - cur_c) / radius2) * HEAD_FLASH * fade;

    // Beam from the previous cursor position to the current one.
    float2 move_dir = float2(1.0, 0.0);
    float2 perp = float2(0.0, 1.0);
    float move_len = 0.0;
    float2 prev_c = cur_c;
    if (valid_rect(d.cursor_trail_prev_edge)) {
        float4 prev = rect_center_size(d.cursor_trail_prev_edge, pixel_dims);
        prev_c = prev.xy;
        float2 move = cur_c - prev_c;
        move_len = length(move);
        if (move_len > 0.5) {
            move_dir = move / move_len;
            perp = float2(-move_dir.y, move_dir.x);
            float dist = segment_distance(px, prev_c, cur_c);
            float core = 1.0 - smoothstep(CORE_WIDTH * scale, CORE_WIDTH * scale + 2.0, dist);
            float halo = exp(-(dist * dist) / radius2);
            glow = max(glow, fade * max(core, halo * 0.75));
        }
    }

    // Sparks fly off the travelled path.
    if (move_len > 0.5 && age < SPARK_LIFETIME + SPARK_EMIT) {
        float lines = move_len / scale;
        int count = clamp(int(ceil(lines * SPARK_DENSITY)), min(4, MAX_SPARKS), clamp(MAX_SPARKS, 1, 64));
        float spark_radius = max(SPARK_SIZE * scale, 0.75);
        float sparks = 0.0;
        for (int i = 0; i < count; i++) {
            float fi = float(i);
            float r1 = hash11(fi * 0.618 + 4.1);
            float r2 = hash11(fi * 1.117 + 11.3);
            float r3 = hash11(fi * 2.317 + 27.1);
            float u = (fi + r1) / float(count);
            float t = age - u * SPARK_EMIT;
            if (t < 0.0 || t >= SPARK_LIFETIME) continue;

            float2 spawn = lerp(prev_c, cur_c, u) + (float2(r2, r3) - 0.5) * scale * 0.6;
            float2 vel = -move_dir * lerp(0.25, 1.0, r2) + perp * (r3 * 2.0 - 1.0) * SPARK_SPREAD;
            vel = normalize(vel + float2(1e-5, 1e-5));
            float distance = SPARK_SPEED * scale * (1.0 - exp(-SPARK_DRAG * t)) / SPARK_DRAG;
            float life = 1.0 - t / SPARK_LIFETIME;
            float disc = saturate(spark_radius * lerp(0.4, 1.0, life) + 0.5 - length(px - (spawn + vel * distance)));
            sparks = max(sparks, disc * life);
        }
        glow = max(glow, sparks * SPARK_OPACITY);
    }

    glow = saturate(glow * GLOW_STRENGTH);
    if (glow <= 0.0) return color;
    return float4(lerp(color.rgb, glow_rgb, glow), color.a);
}
