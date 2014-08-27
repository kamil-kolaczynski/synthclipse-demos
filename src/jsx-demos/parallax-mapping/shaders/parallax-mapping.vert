#version 330

#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

uniform mat4 ModelMatrix = mat4(1.0);
uniform mat4 synth_ViewMatrix;
uniform mat4 synth_ProjectionMatrix;

//! <group name="Light" />

uniform vec3 LightDirection = vec3(0.0, -1.0, 0.0); //! direction[(0.0, -1.0, 0.0)]

layout(location = 0) in vec3 VertexPosition;
layout(location = 1) in vec3 VertexNormal;
layout(location = 2) in vec2 VertexTexCoord;

out VertexData {
	vec3 P;
	vec3 N;
	vec3 L;
	vec3 V;
	vec2 T;
} VertexOut;

void main() {
	mat4 modelView = synth_ViewMatrix * ModelMatrix;
	vec4 P = modelView * vec4(VertexPosition, 1.0);

	mat3 normalMatrix = mat3(modelView);
	VertexOut.N = normalMatrix * VertexNormal;
	VertexOut.L = normalMatrix * (-LightDirection);
	VertexOut.P = P.xyz;
	VertexOut.V = -P.xyz;
	VertexOut.T = VertexTexCoord;

	gl_Position = synth_ProjectionMatrix * P;
}
