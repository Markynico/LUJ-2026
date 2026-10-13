shader_type canvas_item;

uniform float velocidad_linea = 0.5;

void fragment() {
	vec2 mover_uv = vec2(UV.x - (TIME * velocidad_linea), UV.y);
	vec4 in_tex = texture(TEXTURE, mover_uv);
	COLOR = in_tex;
}