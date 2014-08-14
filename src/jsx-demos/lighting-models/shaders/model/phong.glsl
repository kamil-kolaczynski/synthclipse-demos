/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Blinn-Phong
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Phong" />

uniform bool BlinnPhong = false; //! checkbox[false]
uniform float SpecularPower = 300.0; //! slider[10, 300, 1000]
uniform vec3 SpecularColor = vec3(0.7); //! color[0.7, 0.7, 0.7]

vec4 phong(vec3 normal, vec3 viewer, vec3 light) {
	vec3 specular;

	if (BlinnPhong) {
		// Compute the half vector
		vec3 half_vector = normalize(light + viewer);

		// Compute the angle between the half vector and normal
		float HdotN = max(0.0, dot(half_vector, normal));

		// Compute the specular colour
		specular = SpecularColor * pow(HdotN, SpecularPower);
	} else {
		// Compute the reflection vector
		vec3 reflection = normalize(2.0 * normal * dot(normal, light) - light);

		// Compute the angle between the reflection and the viewer
		float RdotV = max(dot(reflection, viewer), 0.0);

		// Compute the specular colour
		specular = SpecularColor * pow(RdotV, SpecularPower);
	}
	// Compute the diffuse term for the Phong equation
	vec3 diffuse = DiffuseColor * max(0.0, dot(normal, light));

	// Determine the final colour
	return vec4(diffuse + specular, 1.0);
}
