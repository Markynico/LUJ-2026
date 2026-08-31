shader_type canvas_item;

uniform vec4 color_borde : source_color = vec4(0.0);
uniform float grosor : hint_range(0.0, 24.0) = 5.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 paso = TEXTURE_PIXEL_SIZE * grosor;
	float alrededor = 0.0;
	for (float x = -1.0; x <= 1.0; x += 1.0) {
		for (float y = -1.0; y <= 1.0; y += 1.0) {
			alrededor = max(alrededor, texture(TEXTURE, UV + vec2(x, y) * paso).a);
		}
	}
	float contorno = clamp(alrededor - base.a, 0.0, 1.0) * color_borde.a;
	COLOR = mix(base, vec4(color_borde.rgb, 1.0), contorno);
	COLOR.a = max(base.a, contorno);
}
