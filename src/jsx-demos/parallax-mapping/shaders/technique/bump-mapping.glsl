/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Per-Pixel_Lighting#Simple_Normal_Mapping
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

vec4 bumpMapping(vec3 V, vec3 L, vec2 T) {
	vec3 N = getNormal(T);

	return phong(N, V, L, T, 1.0);
}
