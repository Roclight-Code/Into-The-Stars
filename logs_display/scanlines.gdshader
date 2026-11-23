shader_type canvas_item;

uniform float line_count = 200.0;
uniform float line_strength : hint_range(0.0, 1.0) = 0.25;
uniform float scroll_speed = 0.02;
uniform float flicker : hint_range(0.0, 0.2) = 0.03;

void fragment() {
	float y = UV.y * line_count + TIME * scroll_speed * line_count;
	float line = 0.5 + 0.5 * sin(y * 6.28318);
	float a = (1.0 - line) * line_strength;
	a += flicker * (0.5 + 0.5 * sin(TIME * 60.0));
	COLOR = vec4(0.0, 0.0, 0.0, a);
}