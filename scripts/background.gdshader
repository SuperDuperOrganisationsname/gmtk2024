shader_type canvas_item;

void fragment(){
	vec4 orig_color = texture(TEXTURE, UV);
	COLOR = vec4(orig_color.r, orig_color.g, orig_color.b, 0.7);
}
