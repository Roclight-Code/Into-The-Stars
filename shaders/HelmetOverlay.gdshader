shader_type canvas_item;

uniform vec4 frame_color : source_color = vec4(0.04, 0.04, 0.06, 1.0);
uniform vec4 glass_tint : source_color = vec4(0.4, 0.7, 1.0, 0.06);
uniform float frame_size = 0.06;      // thickness of the border
uniform float corner_radius = 0.18;   // roundness of the visor opening
uniform float edge_softness = 0.004;
uniform float vignette = 0.35;        // darkening toward the edges

void fragment() {
    vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
    float aspect = res.x / res.y;

    // centered coords, x scaled so corners are round, not stretched
    vec2 p = (UV - 0.5) * vec2(aspect, 1.0);

    // rounded-rectangle distance: negative inside the opening
    vec2 half_size = vec2(0.5 * aspect, 0.5) - vec2(frame_size);
    vec2 q = abs(p) - (half_size - vec2(corner_radius));
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - corner_radius;

    float frame = smoothstep(-edge_softness, edge_softness, d);

    vec4 glass = glass_tint;
    glass.a += smoothstep(-0.25, 0.0, d) * vignette;
    glass.rgb = mix(glass.rgb, vec3(0.0), smoothstep(-0.25, 0.0, d));

    COLOR = mix(glass, frame_color, frame);
}