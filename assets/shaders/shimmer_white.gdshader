shader_type canvas_item;
// Makes the near-white pixels of a painting glow and shimmer (the obstacle outlines).
// Values above 1.0 are picked up by the level's glow (WorldEnvironment).

// A pixel counts as white when its darkest channel is at least this bright.
uniform float white_threshold : hint_range(0.0, 1.0) = 0.85;
// Base brightness of white pixels. Above 1.0 makes them glow.
uniform float glow_strength = 1.6;
// How much the brightness rises and falls as the shimmer passes.
uniform float shimmer_amount = 0.8;
uniform float shimmer_speed = 2.0;
// Shimmer bands across one 1024 px chunk. A whole number keeps chunk edges seamless.
uniform float shimmer_bands = 6.0;
// Per-pixel twinkle on top of the shimmer.
uniform float twinkle_amount = 0.3;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (min(color.r, min(color.g, color.b)) >= white_threshold) {
		vec2 pixel = floor(UV / TEXTURE_PIXEL_SIZE);
		float phase = (pixel.x + pixel.y) * TEXTURE_PIXEL_SIZE.x * TAU * shimmer_bands;
		float wave = 0.5 + 0.5 * sin(TIME * shimmer_speed - phase);
		float twinkle = 0.5 + 0.5 * sin(TIME * 5.0 + hash(pixel) * TAU);
		color.rgb *= glow_strength + shimmer_amount * wave + twinkle_amount * twinkle;
	}
	COLOR = color;
}
