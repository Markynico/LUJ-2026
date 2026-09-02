shader_type canvas_item;

uniform float radio : hint_range(0.0, 200.0) = 24.0;
uniform vec2 tamanio = vec2(500.0, 600.0);

void fragment() {
	vec2 pixel = UV * tamanio;
	vec2 centro = tamanio * 0.5;
	vec2 q = abs(pixel - centro) - (centro - vec2(radio));
	float distancia = length(max(q, vec2(0.0))) - radio;
	COLOR.a *= 1.0 - smoothstep(-1.0, 1.0, distancia);
}
