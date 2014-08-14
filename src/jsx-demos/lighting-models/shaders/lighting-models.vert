#version 330

#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

uniform mat4 ModelMatrix = mat4(1.0);
uniform mat4 synth_ViewMatrix;
uniform mat4 synth_ProjectionMatrix;

uniform vec3 LightDirection = vec3(0.0, -1.0, 0.0); //! direction[(0.0, -1.0, 0.0)]

layout(location = 0) in vec4 VertexPosition;
layout(location = 1) in vec3 VertexNormal;
layout(location = 2) in vec2 VertexTexCoord;

out vec3 N;
out vec3 L;
out vec3 V;
out vec2 T;

void main() {
	mat4 modelView = synth_ViewMatrix * ModelMatrix;
	vec4 P = modelView * VertexPosition;

	mat3 normalMatrix = mat3(modelView);
	N = normalMatrix * VertexNormal;
	L = normalMatrix * (-LightDirection);
	V = -P.xyz;
	T = VertexTexCoord;

	gl_Position = synth_ProjectionMatrix * P;
}
