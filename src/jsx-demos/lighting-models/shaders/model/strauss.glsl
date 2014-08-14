/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Strauss
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Strauss" />

uniform float StraussSmoothness = 0.5; //! slider[0.0, 0.5, 1.0]
uniform float StraussMetalness = 0.5; //! slider[0.0, 0.5, 1.0]
uniform float StraussTransparency = 0.5; //! slider[0.0, 0.5, 1.0]

#define SQR(x) ((x) * (x))

float fresnel(float x) {
	const float kf = 1.12;

	float p = 1.0 / SQR(kf);
	float num = 1.0 / SQR(x - kf) - p;
	float denom = 1.0 / SQR(1.0 - kf) - p;

	return num / denom;
}

float shadow(float x) {
	const float ks = 1.01;

	float p = 1.0 / SQR(1.0 - ks);
	float num = p - 1.0 / SQR(x - ks);
	float denom = p - 1.0 / SQR(ks);

	return num / denom;
}

vec4 strauss(vec3 n, vec3 v, vec3 l) {
	vec3 h = reflect(l, n);

	// Declare any aliases:
	float NdotL = dot(n, l);
	float NdotV = dot(n, v);
	float HdotV = dot(h, v);
	float fNdotL = fresnel(NdotL);
	float s_cubed = StraussSmoothness * StraussSmoothness * StraussSmoothness;

	// Evaluate the diffuse term
	float d = (1.0 - StraussMetalness * StraussSmoothness);
	float Rd = (1.0 - s_cubed) * (1.0 - StraussTransparency);
	vec3 diffuse = NdotL * d * Rd * DiffuseColor;

	// Compute the inputs into the specular term
	float r = (1.0 - StraussTransparency) - Rd;

	float j = fNdotL * shadow(NdotL) * shadow(NdotV);

	// 'k' is used to provide small off-specular
	// peak for very rough surfaces. Can be changed
	// to suit desired results...
	const float k = 0.1;
	float reflect = min(1.0, r + j * (r + k));

	vec3 C1 = vec3(1.0, 1.0, 1.0);
	vec3 Cs = C1 + StraussMetalness * (1.0 - fNdotL) * (DiffuseColor - C1);

	// Evaluate the specular term
	vec3 specular = Cs * reflect;
	specular *= pow(-HdotV, 3.0 / (1.0 - StraussSmoothness));

	// Composite the final result, ensuring
	// the values are >= 0.0 yields better results. Some
	// combinations of inputs generate negative values which
	// looks wrong when rendered...
	diffuse = max(vec3(0.0), diffuse);
	specular = max(vec3(0.0), specular);
	return vec4(diffuse + specular, 1.0);
}
