shader_type canvas_item;
// Draws a sprite's shape in one flat color. Used behind a sprite as a colored glow.

uniform vec3 tint = vec3(0.25, 0.9, 0.85);
// Above 1.0 makes the shape glow.
uniform float energy = 1.6;
uniform float opacity : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	COLOR = vec4(tint * energy, texture(TEXTURE, UV).a * opacity);
}
