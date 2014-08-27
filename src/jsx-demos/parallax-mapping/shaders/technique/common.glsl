#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

uniform sampler2D ColorTex; //! texture["images/BrickTut.jpg"]
uniform sampler2D HeightTex; //! texture["images/BrickTut-heightmap.jpg"]

uniform float NormalDepth = 1.0; //! slider[0.1, 1, 3]

//! <group name="Phong" />

uniform vec3 DiffuseColor = vec3(1.0); //! color[1, 1, 1]
uniform vec3 SpecularColor = vec3(0.3); //! color[0.3, 0.3, 0.3]
uniform float SpecularPower = 300.0; //! slider[10, 300, 1000]

/**
 * http://content.gpwiki.org/D3DBook:(Lighting)_Blinn-Phong
 */
vec4 phong(vec3 normal, vec3 viewer, vec3 light, vec2 texCoord, float shadow) {
	vec3 texColor = texture2D(ColorTex, texCoord).xyz;

	// ambient
	vec3 ambient = vec3(0.2);

	// diffuse
	float lambertianTerm = max(dot(light, normal), 0.0);
	vec3 diffuse = DiffuseColor * lambertianTerm;

	// specular
	vec3 reflected = reflect(-light, normal);
	float RdotV = max(dot(reflected, viewer), 0.0);
	vec3 specular = SpecularColor * pow(RdotV, SpecularPower);

	return vec4((ambient + diffuse * shadow + specular) * texColor, 1.0);
}

vec3 getNormal(vec2 p) {
	float s01 = textureOffset(HeightTex, p, ivec2(-1, 0)).x;
	float s21 = textureOffset(HeightTex, p, ivec2(1, 0)).x;
	float s10 = textureOffset(HeightTex, p, ivec2(0, -1)).x;
	float s12 = textureOffset(HeightTex, p, ivec2(0, 1)).x;

	// Central Difference Method from:
	// http://www.iquilezles.org/www/articles/terrainmarching/terrainmarching.htm
	vec3 n = vec3(s01 - s21, s10 - s12, NormalDepth);
	return normalize(n);
}
