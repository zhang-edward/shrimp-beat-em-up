shader_type canvas_item;

uniform sampler2D gradient_texture : hint_default_white;
uniform bool use_label_gradient = true;
uniform vec2 text_size = vec2(100.0, 30.0);

// NEW UNIFORMS: Provide your label colors so the shader can differentiate them
uniform vec4 font_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float color_threshold : hint_range(0.0, 1.0) = 0.1;

varying vec2 local_uv;

void vertex() {
	if (use_label_gradient) {
		local_uv = VERTEX.xy / text_size;
	} else {
		local_uv = UV;
	}
}

void fragment() {
	vec4 text_color_sampled = texture(TEXTURE, UV);
	vec4 grad_color = texture(gradient_texture, local_uv);
	
	// Calculate how close the pixel color is to your outline color
	float is_outline = distance(text_color_sampled.rgb, outline_color.rgb);
	
	if (is_outline < color_threshold) {
		// Keep the original outline pixel intact
		COLOR = text_color_sampled;
	} else {
		// Apply gradient to the inner text area while preserving alpha
		COLOR.rgb = grad_color.rgb;
		COLOR.a = text_color_sampled.a;
	}
}