shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 element_color : source_color = vec4(0.35, 1.0, 0.86, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.0, 20.0) = 7.0;

void fragment() {
	vec4 scene_color = texture(screen_texture, SCREEN_UV);
	float pulse = 0.88 + 0.12 * sin(TIME * pulse_speed);
	float glow = strength * pulse;
	vec3 element_light = mix(vec3(1.0), element_color.rgb, 0.58);
	vec3 brightened = scene_color.rgb + element_light * glow * 0.28;
	vec3 tinted = mix(brightened, element_color.rgb, glow * 0.10);
	COLOR = vec4(clamp(tinted, vec3(0.0), vec3(1.0)), scene_color.a);
}
