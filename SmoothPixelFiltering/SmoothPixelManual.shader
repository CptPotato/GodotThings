shader_type canvas_item;
render_mode unshaded;

// Texture must have 'Filter'-flag enabled!

// Manual smoothing
// requires you to calculate the filter width manually
vec4 texturePointSmoothAlt(sampler2D smp, vec2 uv, vec2 pixel_size, vec2 filter_width)
{
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) / filter_width + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureLod(smp, uv + uv_dxy_pixels * pixel_size, 0.0f);
}

void fragment()
{
	COLOR = texturePointSmoothAlt(TEXTURE, UV, TEXTURE_PIXEL_SIZE, 0.25f); // filter width is hardcoded in this example
}
