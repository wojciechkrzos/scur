shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.35, 0.05, 0.08, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.05, 0.0, 0.02, 1.0);

void fragment() {
    float t = (UV.x + UV.y) * 0.5;
    COLOR = mix(top_color, bottom_color, t);
}