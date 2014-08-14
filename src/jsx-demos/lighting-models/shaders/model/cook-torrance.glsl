/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Cook-Torrance
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Cook-Torrance" />

uniform float RoughnessValue = 1.0; //! slider[0, 1, 1]
uniform float RefAtNormIncidence = 1.0; //! slider[0, 1, 1]
uniform int RoughnessMode = 0; //! slider[0, 0, 1]
uniform vec3 CookSpecularColor = vec3(0.7); //! color[0.7, 0.7, 0.7]

#define ROUGHNESS_BECKMANN 0
#define ROUGHNESS_GAUSSIAN 1

vec4 cookTorrance(vec3 normal, vec3 viewer, vec3 light) {
	// Compute any aliases and intermediary values
	// -------------------------------------------
	vec3 half_vector = normalize(light + viewer);
	float NdotL = clamp(dot(normal, light), 0.0, 1.0);
	float NdotH = clamp(dot(normal, half_vector), 0.0, 1.0);
	float NdotV = clamp(dot(normal, viewer), 0.0, 1.0);
	float VdotH = clamp(dot(viewer, half_vector), 0.0, 1.0);
	float r_sq = RoughnessValue * RoughnessValue;

	// Evaluate the geometric term
	// --------------------------------
	float geo_numerator = 2.0 * NdotH;
	float geo_denominator = VdotH;

	float geo_b = (geo_numerator * NdotV) / geo_denominator;
	float geo_c = (geo_numerator * NdotL) / geo_denominator;
	float geo = min(1.0, min(geo_b, geo_c));

	// Now evaluate the roughness term
	// -------------------------------
	float roughness;

	if (ROUGHNESS_BECKMANN == RoughnessMode) {
		float roughness_a = 1.0 / (4.0 * r_sq * pow(NdotH, 4));
		float roughness_b = NdotH * NdotH - 1.0;
		float roughness_c = r_sq * NdotH * NdotH;

		roughness = roughness_a * exp(roughness_b / roughness_c);
	}
	if (ROUGHNESS_GAUSSIAN == RoughnessMode) {
		// This variable could be exposed as a variable
		// for the application to control:
		float c = 1.0;
		float alpha = acos(dot(normal, half_vector));
		roughness = c * exp(-(alpha / r_sq));
	}

	// Next evaluate the Fresnel value
	// -------------------------------
	float fresnel = pow(1.0 - VdotH, 5.0);
	fresnel *= (1.0 - RefAtNormIncidence);
	fresnel += RefAtNormIncidence;

	// Put all the terms together to compute
	// the specular term in the equation
	// -------------------------------------
	vec3 Rs_numerator = vec3(fresnel * geo * roughness);
	float Rs_denominator = NdotV * NdotL;
	vec3 Rs = Rs_numerator / Rs_denominator;

	// Put all the parts together to generate
	// the final colour
	// --------------------------------------
	vec3 final = max(0.0, NdotL) * (CookSpecularColor * Rs + DiffuseColor);

	// Return the result
	// -----------------
	return vec4(final, 1.0);
}
