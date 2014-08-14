#version 330

#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

layout(location = 0) out vec4 FragColor;

in vec3 N;
in vec3 L;
in vec3 V;
in vec2 T;

#define PI 3.14159

#define PHONG_MODEL 0
#define COOK_TORRANCE_MODEL 1
#define OREN_NAYAR_MODEL 2
#define STRAUSS_MODEL 3
#define WARD_MODEL 4
#define ASHIKHMIN_SHIRLEY_MODEL 5

uniform int LightingModel = 0; //! combobox[0, "Phong", "Cook-Torrance", "Oren-Nayar", "Strauss", "Ward", "Ashikhmin-Shirley"]
uniform vec3 DiffuseColor = vec3(0.9, 0.8, 1.0); //! color[0.9, 0.8, 1.0]

#include "model/phong.glsl"
#include "model/cook-torrance.glsl"
#include "model/oren-nayar.glsl"
#include "model/strauss.glsl"
#include "model/ward.glsl"
#include "model/ashikhmin-shirley.glsl"

void main() {
	vec3 N = normalize(N);
	vec3 L = normalize(L);
	vec3 V = normalize(V);

	switch (LightingModel) {
	case PHONG_MODEL:
		FragColor = phong(N, V, L);
		break;

	case COOK_TORRANCE_MODEL:
		FragColor = cookTorrance(N, V, L);
		break;

	case OREN_NAYAR_MODEL:
		FragColor = orenNayar(N, V, L);
		break;

	case STRAUSS_MODEL:
		FragColor = strauss(N, V, L);
		break;
	case WARD_MODEL:
		FragColor = ward(N, V, L);
		break;
	case ASHIKHMIN_SHIRLEY_MODEL:
		FragColor = ashikhminShirley(N, V, L);
		break;
	}
}

/*!
 * <preset name="Default">
 *  AshikhminAnisotropy = 3100.0, 5500.0
 *  BlinnPhong = false
 *  CookSpecularColor = 0.7, 0.7, 0.7
 *  DiffuseColor = 0.46, 0.54, 1.0
 *  LightDirection = -0.014281049, -0.7757141, 0.63092285
 *  LightingModel = 4
 *  OrenNayarSimple = false
 *  OrenRoughness = 1.0
 *  RefAtNormIncidence = 0.12
 *  RoughnessMode = 0
 *  RoughnessValue = 1.0
 *  SpecularColor = 0.7, 0.7, 0.7
 *  SpecularPower = 300.0
 *  StraussMetalness = 0.86
 *  StraussSmoothness = 0.41
 *  StraussTransparency = 0.29
 *  WardAnisotropic = false
 *  WardAnisotropicRoughness = 0.5, 0.5
 *  WardRoughness = 1.0
 * </preset>
 */
