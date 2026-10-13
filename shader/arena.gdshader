shader_type canvas_item;

uniform float period = 64.0;
uniform float thickness = 2.0;
uniform float min_px = 1.0;
uniform float min_cell_px = 16.0;
uniform float subdivision = 2.0;
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 grid_color : source_color = vec4(1.0);

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

float pulse_sum(float x, float d) {
	return floor(x) * d + min(fract(x), d);
}

float filtered_pulse(float x, float d, float w) {
	return (pulse_sum(x + 0.5 * w, d) - pulse_sum(x - 0.5 * w, d)) / w;
}

float grid(vec2 world, float p, float px_size) {
	vec2 uv = world / p;
	float w = max(px_size / p, 1e-6);
	float d = clamp(max(thickness / p, min_px * w), 0.0, 1.0);
	float gx = filtered_pulse(uv.x + 0.5 * d, d, w);
	float gy = filtered_pulse(uv.y + 0.5 * d, d, w);
	return gx + gy - gx * gy;
}

void fragment() {
	float px_size = max(fwidth(world_pos.x), fwidth(world_pos.y));

	float level = max(log(min_cell_px * px_size / period) / log(subdivision), 0.0);
	float l = floor(level);
	float p0 = period * pow(subdivision, l);

	float g = mix(grid(world_pos, p0, px_size),
	              grid(world_pos, p0 * subdivision, px_size),
	              level - l);
	COLOR = mix(background_color, grid_color, g);
}