/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Per-Pixel_Lighting#Parallax_Mapping_With_Offset_Limiting
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Parallax" />

uniform float heightScale = 0.05; //! slider[0.005, 0.05, 0.1]

vec4 offsetParallax(vec3 V, vec3 L, vec2 T) {
	// Compute the height at this location
	float height = texture(HeightTex, T).x;
	height = heightScale * height - (heightScale * 0.5);

	// Compute the offset
	vec2 offsetDir = V.xy; // normalize( v.viewdir ).xy;
	T = T + offsetDir * height;

	// Take the samples with the shifted offset
	vec3 N = getNormal(T).xyz;

	return phong(N, V, L, T, 1.0);
}
