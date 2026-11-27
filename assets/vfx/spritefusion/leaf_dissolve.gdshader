shader_type canvas_item;
render_mode unshaded;

// Pixel-random dissolve used when a leaf or a ground leaf runs out of life.
// A random hash per art pixel is discarded as `dissolve` grows, so the sprite
// loses individual pixels instead of fading as a whole (T-0096).
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float seed = 0.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	ivec2 size = textureSize(TEXTURE, 0);
	vec2 px = floor(UV * vec2(size));
	float noise = hash21(px + vec2(seed * 137.0, seed * 311.0));
	if (noise < dissolve) {
		discard;
	}
	COLOR = texture(TEXTURE, UV) * COLOR;
}
