/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Ashikhmin-Shirley
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Ashikhmin-Shirley" />

uniform vec2 AshikhminAnisotropy = vec2(0.5, 0.5); //! slider[(0, 0), (1.0, 1.0), (10000.0, 10000.0)]

vec4 ashikhminShirley(vec3 n, vec3 v, vec3 l) {
	vec3 h = normalize(l + v);

	// Define the coordinate frame
	vec3 epsilon = vec3(1.0, 0.0, 0.0);
	vec3 tangent = normalize(cross(n, epsilon));
	vec3 bitangent = normalize(cross(n, tangent));

	// Generate any useful aliases
	float VdotN = dot(v, n);
	float LdotN = dot(l, n);
	float HdotN = dot(h, n);
	float HdotL = dot(h, l);
	float HdotT = dot(h, tangent);
	float HdotB = dot(h, bitangent);

	vec3 Rd = DiffuseColor;
	vec3 Rs = vec3(0.2);

	const float factor = 1.0;
	float Nu = AshikhminAnisotropy.x * factor;
	float Nv = AshikhminAnisotropy.y * factor;

	// Compute the diffuse term
	vec3 Pd = (28.0 * Rd) / (23.0 * PI);
	Pd *= (vec3(1.0) - Rs);
	Pd *= (1.0 - pow(1.0 - 0.5 * LdotN, 5.0));
	Pd *= (1.0 - pow(1.0 - 0.5 * VdotN, 5.0));

	/*
	 * I know that there is no such factor in the original equation,
	 * but without it models looks very dark:
	 */
	Pd *= 2.0;

	// Compute the specular term
	float ps_num_exp = Nu * HdotT * HdotT + Nv * HdotB * HdotB;
	ps_num_exp /= (1.0 - HdotN * HdotN);

	float Ps_num = sqrt((Nu + 1) * (Nv + 1));
	Ps_num *= pow(HdotN, ps_num_exp);

	float Ps_den = 8.0 * 3.14159 * HdotL;
	Ps_den *= max(LdotN, VdotN);

	vec3 Ps = Rs * (Ps_num / Ps_den);
	Ps *= (Rs + (1.0 - Rs) * pow(1.0 - HdotL, 5.0));

	// Composite the final value:
	return vec4(Pd + Ps, 1.0);
}
