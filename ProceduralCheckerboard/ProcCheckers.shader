shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : hint_color = vec4(0.6f, 0.6f, 0.6f, 1.0f);
uniform float specular;
uniform float metallic : hint_range(0, 1) = 0.0f;
uniform float roughness : hint_range(0, 1) = 0.5f;
uniform float point_size : hint_range(0, 128);

varying vec3 Position;
varying vec3 Normal;

void vertex()
{
	Position = VERTEX;
	Normal = NORMAL;
}

float SquareAntialiased(float coord, float dd) // antialiased square wave
{
	coord += dd * 0.5f;
	
	dd = max(dd, 0.0001f);
	float invdd = 1.0f / dd;
	
	coord = mod(coord, 1.0f);
	float c = min(coord * invdd, 0.5f - (coord - 0.5f) / dd + 0.5f);
	c = clamp(c, 0.0f, 1.0f);
	
	return c;
}

float SXOR(float a, float b) // "smooth" xor, used to combine checker patterns
{
	return abs(a - b);
}

vec4 SXOR4(vec4 a, vec4 b)
{
	return abs(a - b);
}

float Checkers(vec3 coord, vec3 ddxyz, vec3 tripCoeff)
{
	vec3 fade = clamp(1.0f / (ddxyz * 2.0f) - 1.0f, 0.0f, 1.0f);
	
	float cx = SquareAntialiased(coord.x, ddxyz.x);
	float cy = SquareAntialiased(coord.y, ddxyz.y);
	float cz = SquareAntialiased(coord.z, ddxyz.z);
	
	vec3 filter = clamp(1.0f / ddxyz * 0.5f - 0.5f, 0.0f, 1.0f); // smooth, manual filtering
	
	float c = SXOR(cy * filter.y, cz * filter.z) * tripCoeff.x;
	c += SXOR(cz * filter.z, cx * filter.x) * tripCoeff.y;
	c += SXOR(cx * filter.x, cy * filter.y) * tripCoeff.z;
	c += 1.0f - dot(filter, vec3(0.3333f));
	
	return c;
}

vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 tex_size, vec2 filter_width)
{
	float fade = clamp(max(1.0f / filter_width.x, 1.0f / filter_width.y) - 1.0f, 0.0f, 1.0f);
	filter_width = max(filter_width, vec2(1.0f));
	vec2 uv_pixels = uv * tex_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * filter_width + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor / tex_size;
	
	return mix(textureLod(smp, uv + uv_dxy_pixels / tex_size, 0.0f), vec4(0.5f, 0.5f, 0.5f, 1.0f), fade);
}

vec4 TextureTriplanar(sampler2D smp, vec2 texSize, vec3 coord, vec3 ddxyz, vec3 tripCoeff)
{
	vec4 cx = texturePointSmooth(smp, coord.yz, texSize, 1.0f / ddxyz.yz / texSize);
	vec4 cy = texturePointSmooth(smp, coord.zx, texSize, 1.0f / ddxyz.zx / texSize);
	vec4 cz = texturePointSmooth(smp, coord.xy, texSize, 1.0f / ddxyz.xy / texSize);
	
	vec3 filter = clamp(1.0f / ddxyz * 0.5f - 0.5f, 0.0f, 1.0f); // smooth, manual filtering
	
	vec4 c = cx * tripCoeff.x;
	c += cy * tripCoeff.y;
	c += cz * tripCoeff.z;
	
	return c;
}

void fragment()
{
	ALBEDO = albedo.rgb;
	
	vec3 coord = Position.xyz * 4.0f;
	vec3 ddxyz = fwidth(coord) * 1.0f;
	
	vec3 tripCoeff = max((Normal * Normal * 2.0f - 0.5f), 0.001f);
	tripCoeff /= (tripCoeff.x + tripCoeff.y + tripCoeff.z);
	float checkers = Checkers(coord, ddxyz, tripCoeff);
	
	coord = Position.xyz;
	ddxyz = fwidth(coord);
	float checkersL = 1.0f - Checkers(coord, ddxyz, tripCoeff);
	
	checkers = mix(checkers, checkersL, 0.7f);
	
	ALBEDO = mix(ALBEDO * 0.3f, ALBEDO, mix(checkers, 1.0f, metallic * roughness));
	ROUGHNESS = mix(1.0f, 0.5f, checkers * (1.0f - roughness * 0.333f)) * roughness;
	
	METALLIC = metallic;
	SPECULAR = specular;
}
