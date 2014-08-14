/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Oren-Nayar
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Oren-Nayar" />

uniform bool OrenNayarSimple = false; //! checkbox[false]
uniform float OrenRoughness = 1.0; //! slider[0, 1, 1]

vec4 orenNayarComplex(vec3 n, vec3 v, vec3 l) {
	// Compute the other aliases
	float alpha = max(acos(dot(v, n)), acos(dot(l, n)));
	float beta = min(acos(dot(v, n)), acos(dot(l, n)));
	float gamma = dot(v - n * dot(v, n), l - n * dot(l, n));
	float rough_sq = OrenRoughness * OrenRoughness;

	float C1 = 1.0 - 0.5 * (rough_sq / (rough_sq + 0.33));

	float C2 = 0.45 * (rough_sq / (rough_sq + 0.09));
	if (gamma >= 0) {
		C2 *= sin(alpha);
	} else {
		C2 *= (sin(alpha) - pow((2 * beta) / PI, 3));
	}

	float C3 = (1.0 / 8.0);
	C3 *= (rough_sq / (rough_sq + 0.09));
	C3 *= pow((4.0 * alpha * beta) / (PI * PI), 2);

	float A = gamma * C2 * tan(beta);
	float B = (1 - abs(gamma)) * C3 * tan((alpha + beta) / 2.0);

	vec3 final = DiffuseColor * max(0.0, dot(n, l)) * (C1 + A + B);

	return vec4(final, 1.0);
}

vec4 orenNayarSimple(vec3 n, vec3 v, vec3 l) {
	// Compute the other aliases
	float gamma = dot(v - n * dot(v, n), l - n * dot(l, n));

	float rough_sq = OrenRoughness * OrenRoughness;

	float A = 1.0 - 0.5 * (rough_sq / (rough_sq + 0.57));

	float B = 0.45 * (rough_sq / (rough_sq + 0.09));

	float alpha = max(acos(dot(v, n)), acos(dot(l, n)));
	float beta = min(acos(dot(v, n)), acos(dot(l, n)));

	float C = sin(alpha) * tan(beta);

	vec3 final = vec3(A + B * max(0.0, gamma) * C);

	return vec4(DiffuseColor * max(0.0, dot(n, l)) * final, 1.0);
}

vec4 orenNayar(vec3 normal, vec3 viewer, vec3 light) {
	if (OrenNayarSimple) {
		return orenNayarSimple(normal, viewer, light);
	}
	return orenNayarComplex(normal, viewer, light);
}
