shader_type canvas_item;

global uniform float psx_enabled;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 target_res = vec2(320.0, 240.0);//change to (640.0, 480.0) for softer chunkier look (480.0, 360.0) as a middle ground
uniform float color_levels = 32.0;
uniform float dither_strength = 0.6;

const float bayer[16] = float[16](
    0.0, 8.0, 2.0, 10.0,
    12.0, 4.0, 14.0, 6.0,
    3.0, 11.0, 1.0, 9.0,
    15.0, 7.0, 13.0, 5.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    if (psx_enabled > 0.5) {
        uv = (floor(uv * target_res) + 0.5) / target_res;
    }
    vec3 c = texture(screen_tex, uv).rgb;

    if (psx_enabled > 0.5) {
        vec2 p = mod(floor(uv * target_res), 4.0);
        float d = bayer[int(p.y) * 4 + int(p.x)] / 16.0 - 0.5;
        c += d * dither_strength / color_levels;
        c = floor(c * color_levels + 0.5) / color_levels;
    }
    COLOR = vec4(c, 1.0);
}