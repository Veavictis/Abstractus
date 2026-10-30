shader_type canvas_item;
// Pixel-stepped glow around a sprite, in the sprite's own colors or a tint.
// The texture needs transparent padding of at least `radius` pixels (PixelGlow.padded).

uniform int radius : hint_range(1, 8) = 4;
uniform float strength : hint_range(0.0, 1.0) = 0.7;
// Brightness levels in the glow, for a pixel-art look. 0 means smooth.
uniform float steps = 3.0;
uniform bool use_tint = false;
uniform vec3 tint : source_color = vec3(0.25, 0.9, 0.85);
// Gentle pulse of the glow. 0 turns it off.
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.25;
uniform float pulse_speed = 3.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	vec3 total = vec3(0.0);
	float weight_sum = 0.0;
	float glow = 0.0;
	for (int y = -radius; y <= radius; y++) {
		for (int x = -radius; x <= radius; x++) {
			vec2 offset = vec2(float(x), float(y));
			vec4 sample_color = texture(TEXTURE, UV + offset * TEXTURE_PIXEL_SIZE);
			float weight = sample_color.a * max(0.0, 1.0 - length(offset) / (float(radius) + 1.0));
			total += sample_color.rgb * weight;
			weight_sum += weight;
			glow = max(glow, weight);
		}
	}
	if (steps > 0.0) {
		glow = ceil(glow * steps) / steps;
	}
	glow *= strength * (1.0 - pulse_amount + pulse_amount * (0.5 + 0.5 * sin(TIME * pulse_speed)));
	vec3 glow_color = use_tint ? tint : total / max(weight_sum, 0.0001);
	float alpha = source.a + glow * (1.0 - source.a);
	vec3 rgb = (source.rgb * source.a + glow_color * glow * (1.0 - source.a)) / max(alpha, 0.0001);
	COLOR = vec4(rgb, alpha);
}
