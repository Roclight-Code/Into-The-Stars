shader_type canvas_item;

uniform float line_count = 60.0;                          // lines from top to bottom of the screen
uniform float line_thickness : hint_range(0.05, 0.95) = 0.5;  // how much of each line's slot is filled
uniform float line_softness : hint_range(0.0, 0.5) = 0.15;    // fuzzy edge of each line
uniform float line_strength : hint_range(0.0, 1.0) = 0.3;     // how visible the lines are
uniform float gap_darkness : hint_range(0.0, 1.0) = 0.0;      // darkens the space between lines
uniform vec4 tint : source_color = vec4(0.2, 1.0, 0.4, 1.0);
uniform float scroll_speed = 0.02;

uniform float pulse_strength : hint_range(0.0, 0.2) = 0.03;
uniform float pulse_speed : hint_range(0.0, 5.0) = 0.4;

void fragment() {
	float y = UV.y * line_count + TIME * scroll_speed * line_count;
	float d = abs(fract(y) - 0.5) * 2.0;   // 0 at the middle of a line's slot, 1 at its edge
	float band = 1.0 - smoothstep(max(line_thickness - line_softness, 0.0), line_thickness, d);

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed * 6.28318);
	float a = line_strength + pulse_strength * pulse;

	COLOR = mix(vec4(0.0, 0.0, 0.0, gap_darkness), vec4(tint.rgb, a), band);
}
