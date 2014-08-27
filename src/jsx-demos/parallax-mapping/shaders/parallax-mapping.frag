#version 330

#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

#define NONE 0
#define BUMP_MAPPING 1
#define OFFSET_PARALLAX_MAPPING 2
#define STEEP_PARALLAX_MAPPING 3

layout(location = 0) out vec4 FragColor;

in VertexData {
	vec3 P;
	vec3 N;
	vec3 L;
	vec3 V;
	vec2 T;
} VertexIn;

uniform int MappingType; //! combobox[2, "none", "bump", "parallax", "steep parallax"]

#include "technique/common.glsl"
#include "technique/bump-mapping.glsl"
#include "technique/offset-parallax-mapping.glsl"
#include "technique/steep-parallax-mapping.glsl"

/**
 * https://www.opengl.org/discussion_boards/showthread.php/162857-Computing-the-tangent-space-in-the-fragment-shader
 */
mat3 computeTangentSpaceMatrix() {
	vec3 A = dFdx(VertexIn.P);
	vec3 B = dFdy(VertexIn.P);

	vec2 P = dFdx(VertexIn.T);
	vec2 Q = dFdy(VertexIn.T);

	// Formula from:
	// http://content.gpwiki.org/D3DBook:(Lighting)_Per-Pixel_Lighting#Moving_From_Per-Vertex_To_Per-Pixel
	float fraction = 1.0f / (P.x * Q.y - Q.x * P.y);
	vec3 normal = normalize(cross(A, B));

	vec3 tangent = vec3(
			(Q.y * A.x - P.y * B.x) * fraction,
			(Q.y * A.y - P.y * B.y) * fraction,
			(Q.y * A.z - P.y * B.z) * fraction);

	vec3 bitangent = vec3(
			(P.x * B.x - Q.x * A.x) * fraction,
			(P.x * B.y - Q.x * A.y) * fraction,
			(P.x * B.z - Q.x * A.z) * fraction);

	// Some simple aliases
	float NdotT = dot(normal, tangent);
	float NdotB = dot(normal, bitangent);
	float TdotB = dot(tangent, bitangent);

	// Apply Gram-Schmidt orthogonalization
	tangent = tangent - NdotT * normal;
	bitangent = bitangent - NdotB * normal - TdotB * tangent;

	// Pack the vectors into the matrix output
	mat3 tsMatrix;

	tsMatrix[0] = tangent;
	tsMatrix[1] = bitangent;
	tsMatrix[2] = normal;

	return transpose(tsMatrix);
}

void main() {
	mat3 tsMatrix = computeTangentSpaceMatrix();

	vec2 T = VertexIn.T;
	vec3 L = normalize(tsMatrix * VertexIn.L);
	vec3 V = normalize(tsMatrix * VertexIn.V);

	switch(MappingType) {
	case NONE:
		vec3 N = normalize(tsMatrix * VertexIn.N);
		FragColor = phong(N, V, L, T, 1.0);
		break;
	case BUMP_MAPPING:
		FragColor = bumpMapping(V, L, T);
		break;
	case OFFSET_PARALLAX_MAPPING:
		FragColor = offsetParallax(V, L, T);
		break;
	case STEEP_PARALLAX_MAPPING:
		FragColor = steepParallax(V, L, T);
		break;
	}
}

/*!
 * <preset name="Default">
 *  ColorTex = images/BrickTut.jpg
 *  DiffuseColor = 1.0, 1.0, 1.0
 *  HeightTex = images/BrickTut-heightmap.jpg
 *  LightDirection = 0.30306727, -0.82018447, 0.48522964
 *  MappingType = 3
 *  MaxSamples = 20
 *  MinSamples = 1
 *  NormalDepth = 1.0
 *  ShadowOffset = 0.2256
 *  SpecularColor = 0.4, 0.4, 0.4
 *  SpecularPower = 300.0
 *  SteepHeightScale = 0.065799996
 *  UseShadow = true
 *  heightScale = 0.07245
 * </preset>
 */

