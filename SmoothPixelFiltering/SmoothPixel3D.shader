shader_type spatial;
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : hint_color = vec4(1.0f);
uniform sampler2D texture_albedo : hint_albedo;

uniform float metallic : hint_range(0, 1) = 0.0f;
uniform float roughness : hint_range(0, 1) = 1.0f;
uniform sampler2D texture_roughness_metallic : hint_white;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex()
{
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size)
{
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

void fragment()
{
	vec2 base_uv = UV;
	vec2 texSize = 1.0f / vec2(textureSize(texture_albedo, 0)); // size of one pixel of the texture
	
	vec4 albedo_tex = texturePointSmooth(texture_albedo, base_uv, texSize);
	
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a;
	
	vec2 roughness_metallic_tex = texturePointSmooth(texture_roughness_metallic, base_uv, texSize).rg;
	ROUGHNESS = roughness_metallic_tex.r * roughness;
	METALLIC = roughness_metallic_tex.g * metallic;
	SPECULAR = 0.5f;
}
