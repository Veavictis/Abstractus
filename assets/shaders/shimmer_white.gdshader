shader_type canvas_item;
// Makes the near-white pixels of a painting (the obstacle outlines) glow and pulse:
// a pixel-stepped halo spreads around them and the whole glow breathes in and out, with a
// lighter shimmer wave sweeping across on top.

// A pixel counts as white when its darkest channel is at least this bright.
uniform float white_threshold : hint_range(0.0, 1.0) = 0.85;
// Halo reach in pixels around white pixels. Keep it small; cost grows with its square.
uniform int glow_radius : hint_range(0, 8) = 6;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.9;
// The whole glow breathing in and out. 0 turns it off.
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.7;
// Pulses per second.
uniform float pulse_rate = 0.6;
// Brightness levels in the halo, for a pixel-art look. 0 means smooth.
uniform float glow_steps = 3.0;
// How much the outline and halo brighten and dim as the shimmer passes.
uniform float shimmer_amount : hint_range(0.0, 1.0) = 0.3;
uniform float shimmer_speed = 2.0;
// Shimmer bands across one 1024 px chunk. A whole number keeps chunk edges seamless.
uniform float shimmer_bands = 6.0;
// Per-pixel twinkle on the outline itself.
uniform float twinkle_amount : hint_range(0.0, 1.0) = 0.35;

// Set every frame by BeatPulse (scripts/components/beat_pulse.gd), declared in project.godot:
// where the beat rings start (world position), how far out they start and stop (the
// player's edge and its pulse reach, in pixels), seconds since each of the last 4 rings
// started, and each ring's color.
global uniform vec2 beat_origin;
global uniform float beat_inner;
global uniform float beat_outer;
global uniform vec4 beat_ages;
global uniform vec4 beat_color_0;
global uniform vec4 beat_color_1;
global uniform vec4 beat_color_2;
global uniform vec4 beat_color_3;
// A pixel counts as black when its brightest channel is at most this.
uniform float black_threshold : hint_range(0.0, 1.0) = 0.12;
// How strongly the black parts take on a ring's color at its brightest.
uniform float beat_strength : hint_range(0.0, 1.0) = 0.35;
// Most pixels of color trailing behind a ring's front edge. A small pulse is filled in.
uniform float ring_width = 140.0;
// Seconds a ring takes to spread from the inner to the outer edge, fading as it goes.
uniform float ring_life = 0.36;

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// How much of one ring covers a pixel `dist` pixels from the center, `age` seconds in.
float ring(float dist, float age) {
	float progress = clamp(age / ring_life, 0.0, 1.0);
	float front = mix(beat_inner, beat_outer, progress);
	float behind = front - dist;
	if (dist < beat_inner || behind < -1.0) {
		return 0.0;
	}
	// Soft 1-pixel front edge, then fading out over ring_width behind it.
	float body = 1.0 - smoothstep(0.0, ring_width, behind);
	return body * clamp(behind + 1.0, 0.0, 1.0) * (1.0 - progress);
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

bool is_white(vec4 color) {
	return min(color.r, min(color.g, color.b)) >= white_threshold;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 pixel = floor(UV / TEXTURE_PIXEL_SIZE);
	float phase = (pixel.x + pixel.y) * TEXTURE_PIXEL_SIZE.x * TAU * shimmer_bands;
	float wave = 0.5 + 0.5 * sin(TIME * shimmer_speed - phase);
	float shimmer = 1.0 - shimmer_amount + shimmer_amount * wave;
	float pulse = 1.0 - pulse_amount * (0.5 + 0.5 * cos(TIME * TAU * pulse_rate));

	// Rings of the beat colors spread through the black parts. Near-black blends in softly so
	// edges stay smooth. Distance is in whole pixels, for a pixel-art edge.
	float brightest = max(color.r, max(color.g, color.b));
	float black = (1.0 - smoothstep(black_threshold, black_threshold + 0.05, brightest)) * beat_strength;
	float dist = length(floor(world_position) - floor(beat_origin));
	color.rgb = mix(color.rgb, beat_color_0.rgb, black * ring(dist, beat_ages.x));
	color.rgb = mix(color.rgb, beat_color_1.rgb, black * ring(dist, beat_ages.y));
	color.rgb = mix(color.rgb, beat_color_2.rgb, black * ring(dist, beat_ages.z));
	color.rgb = mix(color.rgb, beat_color_3.rgb, black * ring(dist, beat_ages.w));

	if (is_white(color)) {
		float twinkle = 0.5 + 0.5 * sin(TIME * 5.0 + hash(pixel) * TAU);
		// Dim slightly at the low point so the brightening is visible on pure white.
		color.rgb *= mix(0.6, 1.0, shimmer * pulse) * (1.0 - twinkle_amount * 0.5 * (1.0 - twinkle));
	} else if (glow_radius > 0) {
		float halo = 0.0;
		for (int y = -glow_radius; y <= glow_radius; y++) {
			for (int x = -glow_radius; x <= glow_radius; x++) {
				vec2 offset = vec2(float(x), float(y));
				if (is_white(texture(TEXTURE, UV + offset * TEXTURE_PIXEL_SIZE))) {
					halo = max(halo, 1.0 - length(offset) / (float(glow_radius) + 1.0));
				}
			}
		}
		if (glow_steps > 0.0) {
			halo = ceil(halo * glow_steps) / glow_steps;
		}
		color.rgb = mix(color.rgb, vec3(1.0), halo * glow_strength * shimmer * pulse);
	}
	COLOR = color;
}
