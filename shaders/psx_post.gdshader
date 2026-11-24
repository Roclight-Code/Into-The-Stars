shader_type canvas_item;

global uniform float psx_enabled;
global uniform float psx_focus;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform vec2 target_res = vec2(320.0, 240.0);
uniform vec2 focus_res = vec2(640.0, 480.0);
uniform float color_levels = 32.0;
uniform float focus_color_levels = 64.0;
uniform float dither_strength = 0.6;
uniform float focus_dither_strength = 0.25;

const float bayer[16] = float[16](
    0.0, 8.0, 2.0, 10.0,
    12.0, 4.0, 14.0, 6.0,
    3.0, 11.0, 1.0, 9.0,
    15.0, 7.0, 13.0, 5.0);

void fragment() {
    vec2 res = mix(target_res, focus_res, psx_focus);
    float levels = mix(color_levels, focus_color_levels, psx_focus);
    float dither = mix(dither_strength, focus_dither_strength, psx_focus);

    vec2 uv = SCREEN_UV;
    if (psx_enabled > 0.5) {
        uv = (floor(uv * res) + 0.5) / res;
    }
    vec3 c = texture(screen_tex, uv).rgb;

    if (psx_enabled > 0.5) {
        vec2 p = mod(floor(uv * res), 4.0);
        float d = bayer[int(p.y) * 4 + int(p.x)] / 16.0 - 0.5;
        c += d * dither / levels;
        c = floor(c * levels + 0.5) / levels;
    }
    COLOR = vec4(c, 1.0);
}