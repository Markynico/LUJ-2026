shader_type canvas_item;

uniform float velocidad = 1.0;

void fragment() {
    vec2 uv = UV;
    uv.x += TIME * velocidad;
    COLOR = texture(TEXTURE, uv);
}