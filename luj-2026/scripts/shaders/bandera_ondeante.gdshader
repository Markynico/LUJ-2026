shader_type canvas_item;

uniform float intensidad : hint_range(0.0, 0.2) = 0.03;
uniform float ondulacion_vertical : hint_range(0.0, 0.05) = 0.008;
uniform vec2 escala_tiempo = vec2(0.25, 0.1);
uniform vec2 escala_uv = vec2(0.4, 0.6);
uniform sampler2D textura_ruido : repeat_enable;

varying vec4 color_modulate;

void vertex() {
	color_modulate = COLOR;
}

void fragment() {
	float ruido = texture(textura_ruido, UV * escala_uv + TIME * escala_tiempo).r - 0.5;
	vec2 uv = UV + vec2(ruido * 2.0 * intensidad * UV.y, ruido * 2.0 * ondulacion_vertical * UV.y);
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0);
	} else {
		COLOR = texture(TEXTURE, uv) * color_modulate;
	}
}
