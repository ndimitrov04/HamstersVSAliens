shader_type canvas_item;

render_mode blend_mix;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int blur_type = 0; // 0 = Xor, 1 = Monks, 2 = Nodev Single, 3 = Nodev Multi
uniform int blur_amount = 16;
uniform float blur_radius = 1.5;
uniform vec2 blur_direction = vec2(1.0, 1.0);

uniform float tint_strength : hint_range(0.0, 1.0) = 0.3; // Black tint intensity
uniform float alpha : hint_range(0.0, 1.0) = 0.6; // Transparency level

// Xor's Gaussian Blur (Radial)
vec4 texture_xorgaussian(sampler2D tex, vec2 uv, vec2 pixel_size, float blurriness, int iterations, int quality){
	float pi = 6.2831;
	vec2 radius = blurriness / (1.0 / pixel_size).xy;
	vec4 blurred_tex = texture(tex, uv);

	for (float d = 0.0; d < pi; d += pi / float(iterations)){
		for (float i = 1.0 / float(quality); i <= 1.0; i += 1.0 / float(quality)){
			vec2 offset = vec2(cos(d), sin(d)) * radius * i;
			blurred_tex += texture(tex, uv + offset);
		}
	}
	blurred_tex /= float(quality) * float(iterations) + 1.0;
	return blurred_tex;
}

// Monks' Multi-pass Blur
vec4 texture_monksgaussian_multipass(sampler2D tex, vec2 uv, vec2 pixel_size, int iterations, vec2 direction){
	vec4 blurred_tex = vec4(0.0);
	vec2 resolution = 1.0 / pixel_size;

	for (int i = 0; i < iterations; i++){
		float size = float(iterations - i);
		vec2 off1 = vec2(1.3846153846) * (direction * size);
		vec2 off2 = vec2(3.2307692308) * (direction * size);

		blurred_tex += texture(tex, uv) * 0.2270270270;
		blurred_tex += texture(tex, uv + (off1 / resolution)) * 0.3162162162;
		blurred_tex += texture(tex, uv - (off1 / resolution)) * 0.3162162162;
		blurred_tex += texture(tex, uv + (off2 / resolution)) * 0.0702702703;
		blurred_tex += texture(tex, uv - (off2 / resolution)) * 0.0702702703;
	}

	blurred_tex /= float(iterations) + 1.0;
	return blurred_tex;
}

// Nodev Single-pass
vec4 texture_nodevgaussian_singlepass(sampler2D tex, vec2 uv, vec2 pixel_size, float blurriness, float radius){
	float pi = 3.1416;
	float n = 0.0015;
	vec4 blurred_tex = vec4(0);
	float weight = 0.0;

	for (float i = -blurriness; i <= blurriness; i++){
		float d = i / pi;
		vec2 offset = vec2(cos(d), sin(d)) * radius * i;
		vec2 sample_uv = uv + pixel_size * offset;
		blurred_tex += texture(tex, sample_uv) * n;
		if (i <= 0.0) n += 0.0015;
		else n -= 0.0015;
		weight += n;
	}

	blurred_tex *= 1.0 / weight;
	return blurred_tex;
}

// Nodev Multi-pass
vec4 texture_nodevgaussian_multipass(sampler2D tex, vec2 uv, vec2 pixel_size, float blurriness, vec2 direction){
	float n = 0.0015;
	vec4 blurred_tex = vec4(0);
	float weight = 0.0;

	for (float i = -blurriness; i <= blurriness; i++){
		vec2 offset = pixel_size * (direction * i);
		blurred_tex += texture(tex, uv + offset) * n;
		if (i <= 0.0) n += 0.0015;
		else n -= 0.0015;
		weight += n;
	}

	blurred_tex *= 1.0 / weight;
	return blurred_tex;
}

void fragment() {
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
	vec4 blurred_result;

	if (blur_type == 0) {
		blurred_result = texture_xorgaussian(SCREEN_TEXTURE, uv, SCREEN_PIXEL_SIZE, float(blur_amount), 16, 4);
	}
	else if (blur_type == 1) {
		blurred_result = texture_monksgaussian_multipass(SCREEN_TEXTURE, uv, SCREEN_PIXEL_SIZE, blur_amount, blur_direction);
	}
	else if (blur_type == 2) {
		blurred_result = texture_nodevgaussian_singlepass(SCREEN_TEXTURE, uv, SCREEN_PIXEL_SIZE, float(blur_amount), blur_radius);
	}
	else if (blur_type == 3) {
		blurred_result = texture_nodevgaussian_multipass(SCREEN_TEXTURE, uv, SCREEN_PIXEL_SIZE, float(blur_amount), blur_direction);
	}
	else {
		blurred_result = texture(SCREEN_TEXTURE, uv);
	}

	// Apply black tint
	blurred_result.rgb = mix(blurred_result.rgb, vec3(0.0), tint_strength);
	blurred_result.a = alpha;

	COLOR = blurred_result;
}
