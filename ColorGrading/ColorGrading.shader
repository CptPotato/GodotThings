shader_type canvas_item;
render_mode unshaded;

uniform vec4 ColorGradeHigh : hint_color = vec4(0.5f, 0.5f, 0.5f, 1.0f); // Color Grading for light colors (rgb: color, a: input saturation)
uniform vec4 ColorGradeLow : hint_color = vec4(0.5f, 0.5f, 0.5f, 1.0f); // Color Grading for dark colors (rgb: color, a: input saturation)
uniform float ColorGradeFalloff : hint_range(-2.0f, 2.0f) = 0.0f; // Adjustment to low-high falloff

vec3 ColorGrade(vec3 color, vec4 gradeLow, vec4 gradeHigh, float falloff)
{
	float gray = (color.r + color.g + color.b) / 3.0f;
	
	vec4 grade = mix(gradeLow, gradeHigh, pow(gray, falloff));
	
	vec3 w = (2.0f * color - 1.0f);
	w = 0.25f - clamp(w * w, 0.0f, 1.0f) * 0.25f;
	
	return mix(vec3(gray), color, grade.a) + (grade.rgb * 2.0f - 1.0f) * w;
}

void fragment()
{
	COLOR = textureLod(TEXTURE, UV, 0.0f); // you may want to use SCREEN_TEXTURE depending on your setup
	COLOR.rgb = ColorGrade(COLOR.rgb, ColorGradeLow, ColorGradeHigh, pow(2.0f, -ColorGradeFalloff));
}