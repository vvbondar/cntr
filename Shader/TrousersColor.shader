shader_type canvas_item;

uniform bool is_player_two = false;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	
	if(is_player_two)
	{
    	vec4 player_one_color = vec4(0.12, 0.22, 0.93, 1.0); // Bill's  R:32  G:56 B:236 
		vec4 player_two_color = vec4(0.85, 0.16, 0.0, 1.0);  // Lance's R:216 G:40 B:0
															 // cyan R:0, G:128 B: 136
    	vec4 d4 = abs(pixel_color - player_one_color);
    	float delta = max(max(max(d4.r, d4.g), d4.b), d4.a);
	
		if(delta < 0.01) {
        	pixel_color = player_two_color;
		}  
	}
	
	COLOR = pixel_color;
}