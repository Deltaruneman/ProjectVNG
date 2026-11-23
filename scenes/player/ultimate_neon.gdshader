shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

uniform sampler2D sprite_texture : source_color, filter_nearest;
uniform vec4 element_color : source_color = vec4(0.35, 1.0, 0.86, 1.0);
uniform vec4 frame_uv_rect = vec4(0.0, 0.0, 1.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 texel_size = 1.0 / vec2(textureSize(sprite_texture, 0));
	vec2 frame_min = frame_uv_rect.xy + texel_size * 0.5;
	vec2 frame_max = frame_uv_rect.xy + frame_uv_rect.zw - texel_size * 0.5;
	vec2 sample_uv = clamp(UV, frame_min, frame_max);
	float body_alpha = texture(sprite_texture, sample_uv).a * COLOR.a;
	float outline_alpha = 0.0;
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + vec2(texel_size.x, 0.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv - vec2(texel_size.x, 0.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + vec2(0.0, texel_size.y), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv - vec2(0.0, texel_size.y), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + texel_size * vec2(1.0, 1.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + texel_size * vec2(1.0, -1.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + texel_size * vec2(-1.0, 1.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + texel_size * vec2(-1.0, -1.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + vec2(texel_size.x * 2.0, 0.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv - vec2(texel_size.x * 2.0, 0.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv + vec2(0.0, texel_size.y * 2.0), frame_min, frame_max)).a);
	outline_alpha = max(outline_alpha, texture(sprite_texture, clamp(sample_uv - vec2(0.0, texel_size.y * 2.0), frame_min, frame_max)).a);
	float edge = clamp(outline_alpha - body_alpha, 0.0, 1.0);
	if (edge < 0.025 || intensity <= 0.001) {
		discard;
	}
	float phase = TIME * 10.0 + sample_uv.x * 18.0 + sample_uv.y * 25.0;
	float shimmer = 0.5 + 0.5 * sin(phase);
	float sparkle_seed = sin(dot(floor(sample_uv * vec2(13.0, 17.0)), vec2(12.9898, 78.233)));
	float sparkle = step(0.965, fract(sparkle_seed * 43758.5453 + TIME * 0.65));
	ALBEDO = element_color.rgb * (0.8 + shimmer * 0.2 + sparkle * 0.35);
	EMISSION = element_color.rgb * (0.7 + shimmer * 0.8 + sparkle * 1.4) * intensity;
	ALPHA = clamp(edge * intensity * (0.5 + shimmer * 0.25 + sparkle * 0.65), 0.0, 1.0);
}
