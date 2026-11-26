shader_type canvas_item;

uniform float line_count = 90.0;
uniform float line_strength : hint_range(0.0, 1.0) = 0.3;
uniform vec4 tint : source_color = vec4(0.2, 1.0, 0.4, 1.0);
uniform float scroll_speed = 0.02;

uniform float pulse_strength : hint_range(0.0, 0.2) = 0.03;
uniform float pulse_speed : hint_range(0.0, 5.0) = 0.4;

void fragment() {
	float y = UV.y * line_count + TIME * scroll_speed * line_count;
	float line = 0.5 + 0.5 * sin(y * 6.28318);
	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed * 6.28318);
	float a = line_strength + pulse_strength * pulse;
	COLOR = vec4(mix(vec3(0.0), tint.rgb, line), a);
}