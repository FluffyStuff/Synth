#version 120
#define MAX_LIGHTS 2

uniform sampler2D tex;
uniform int light_count;

varying vec2 frag_texture_coord;
varying vec3 frag_normal;
varying vec3 frag_camera_normal;

varying vec3 light_normals[MAX_LIGHTS];
varying float light_intensity[MAX_LIGHTS];
varying vec3 light_colors[MAX_LIGHTS];

// Material
uniform vec4 ambient_color;
uniform int ambient_blend_type;

uniform vec4 diffuse_color;
uniform int diffuse_blend_type;

uniform vec4 specular_color;
uniform int specular_blend_type;

uniform float specular_exponent;
uniform float alpha;

/* BLEND_TYPE
0 = SRC_COLOR
1 = DST_COLOR
*/

vec4 color_blend(vec4 color_src, vec4 color_dst, int blend_type)
{
	switch (blend_type)
	{
	default:
	case 0:
		return color_src;
	case 1:
		return color_dst;
	case 2:
		return vec4(color_src.xyz * color_dst.a + color_dst.xyz * color_dst.a, max(color_src.a, color_dst.a));
	}
}

vec4 calculate_lighting_factor()
{		
	float blend_factor = 0.005;
	float constant_factor = 0.01;
	float linear_factor = 0.8;
	float quadratic_factor = 0.5;
		
	vec3 normal = normalize(frag_normal);
	
	vec3 diffuse = out_color.xyz * 0.02;
	vec3 specular = vec3(0);
	vec3 c = out_color.xyz;
	
	for (int i = 0; i < light_count; i++)
	{
		float intensity = light_intensity[i];
		
		float lnlen = max(length(light_normals[i]), 1);
		vec3 ln = normalize(light_normals[i]);
		vec3 cm = normalize(frag_camera_normal);
		
		float d = max(dot(normal, ln) / 1, 0);
		float plus = 0;
		plus += d * constant_factor;
		plus += d / lnlen * linear_factor;
		plus += d / pow(lnlen, 2) * quadratic_factor;
		
		diffuse += (c * (1-blend_factor) + light_colors[i] * blend_factor) * plus * intensity;
		
		if (dot(ln, normal) > 0) // Only reflect on the correct side
		{
			float s = max(dot(cm, reflect(-ln, normal)), 0);
			float spec = pow(s, specular_exponent);
			
			float p = 0;
			p += spec * constant_factor;
			p += spec / lnlen * linear_factor;
			p += spec / pow(lnlen, 2) * quadratic_factor;
			
			p = max(p, 0) * intensity;
			
			specular += (light_colors[i] * (1-blend_factor) + out_color.xyz * blend_factor) * p;
		}
	}
	
	out_color.xyz = diffuse + specular;
	
	out_color.xyz /= max(pow(length(frag_camera_normal) / 5, 1.0) / 10, 1);
	out_color.a *= alpha;
}

void main()
{
	if (alpha <= 0)
		discard;
	
	vec4 ambient = ambient_color;
	if (ambient_texture_mode != 0)
		ambient = color_blend(ambient, texture2D(tex, frag_texture_coord), ambient_blend_type);
	
	vec4 diffuse = diffuse_color;
	if (diffuse_texture_mode != 0)
		diffuse = color_blend(diffuse, texture2D(tex, frag_texture_coord), diffuse_blend_type);
	
	vec4 specular = specular_color;
	if (specular_texture_mode != 0)
		specular = color_blend(specular, texture2D(tex, frag_texture_coord), specular_blend_type);
	
	if (ambient.a <= 0 && diffuse.a <= 0 && specular.a <= 0)
		discard;
	
	vec4 lighting_factor = calculate_lighting_factor();
	
	vec4 out_color = ambient + lighting_factor;
	if (out_color.a <= 0)
		discard;
	
	gl_FragColor = out_color;
}