/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Ward
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Ward" />

uniform bool WardAnisotropic = false; //! checkbox[false]
uniform vec2 WardAnisotropicRoughness = vec2(0.5, 0.5); //! slider[(0, 0), (0.5, 0.5), (1, 1)]
uniform float WardRoughness = 1.0; //! slider[0, 1, 1]

vec4 wardIsotropic(vec3 n, vec3 v, vec3 l) {
	vec3 h = normalize(l + v);

	// Generate any useful aliases
	float VdotN = dot(v, n);
	float LdotN = dot(l, n);
	float HdotN = dot(h, n);
	float r_sq = (WardRoughness * WardRoughness) + 1e-5;
	// (Adding a small bias to r_sq stops unexpected
	//  results caused by divide-by-zero)

	// Define material properties
	vec3 Ps = vec3(1.0, 1.0, 1.0);

	// Compute the specular term
	float exp_a = -pow(tan(acos(HdotN)), 2);
	float spec_num = exp(exp_a / r_sq);

	float spec_den = 4.0 * 3.14159 * r_sq;
	spec_den *= sqrt(LdotN * VdotN);

	vec3 Specular = Ps * (spec_num / spec_den);

	// Composite the final value:
	return vec4(dot(n, l) * (DiffuseColor + Specular), 1.0);
}

vec4 wardAnispotropic(vec3 n, vec3 v, vec3 l) {
	vec3 h = normalize(l + v);

	// Apply a small bias to the roughness
	// coefficients to avoid divide-by-zero
	vec2 anisotropicRoughness = WardAnisotropicRoughness + vec2(1e-5, 1e-5);

	// Define the coordinate frame
	vec3 epsilon = vec3(1.0, 0.0, 0.0);
	vec3 tangent = normalize(cross(n, epsilon));
	vec3 bitangent = normalize(cross(n, tangent));

	// Define material properties
	vec3 Ps = vec3(1.0, 1.0, 1.0);

	// Generate any useful aliases
	float VdotN = dot(v, n);
	float LdotN = dot(l, n);
	float HdotN = dot(h, n);
	float HdotT = dot(h, tangent);
	float HdotB = dot(h, bitangent);

	// Evaluate the specular exponent
	float beta_a = HdotT / anisotropicRoughness.x;
	beta_a *= beta_a;

	float beta_b = HdotB / anisotropicRoughness.y;
	beta_b *= beta_b;

	float beta = -2.0 * ((beta_a + beta_b) / (1.0 + HdotN));

	// Evaluate the specular denominator
	float s_den = 4.0 * 3.14159;
	s_den *= anisotropicRoughness.x;
	s_den *= anisotropicRoughness.y;
	s_den *= sqrt(LdotN * VdotN);

	// Compute the final specular term
	vec3 Specular = Ps * (exp(beta) / s_den);

	// Composite the final value:
	return vec4(dot(n, l) * (DiffuseColor + Specular), 1.0);
}

vec4 ward(vec3 n, vec3 v, vec3 l) {
	if (WardAnisotropic) {
		return wardAnispotropic(n, v, l);
	} else {
		return wardIsotropic(n, v, l);
	}
}
