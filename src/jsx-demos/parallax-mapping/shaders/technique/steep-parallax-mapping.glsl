/*
 * http://content.gpwiki.org/D3DBook:(Lighting)_Per-Pixel_Lighting#Ray-Traced
 */
#ifdef SYNTHCLIPSE
#include <synthclipse>
#endif

//! <group name="Steep Parallax" />

uniform int MinSamples; //! slider[1, 1, 100]
uniform int MaxSamples; //! slider[20, 20, 256]
uniform bool UseShadow; //! checkbox[true]
uniform float SteepHeightScale; //! slider[0.005, 0.05, 0.1]
uniform float ShadowOffset; //! slider[0.01, 0.05, 0.5]

#define SQR(x) ((x) * (x))

vec2 raymarch(vec2 startPos, vec3 dir) {
	// Compute initial parallax displacement direction:
	vec2 parallaxDirection = normalize(dir.xy);

	// The length of this vector determines the
	// furthest amount of displacement:
	float parallaxLength = sqrt(1.0 - SQR(dir.z));
	parallaxLength /= dir.z;

	// Compute the actual reverse parallax displacement vector:
	vec2 parallaxOffset = parallaxDirection * parallaxLength;

	// Need to scale the amount of displacement to account
	// for different height ranges in height maps.
	parallaxOffset *= SteepHeightScale;

	// corrected for tangent space. Normal is always z=1 in TS and
	// v.viewdir is in tangent space as well...
	int numSteps = int(mix(MaxSamples, MinSamples, dir.z));

	float currHeight = 0.0;
	float stepSize = 1.0 / float(numSteps);
	int stepIndex = 0;
	vec2 texCurrentOffset = startPos;
	vec2 texOffsetPerStep = stepSize * parallaxOffset;

	vec2 resultTexPos = vec2(texCurrentOffset - (texOffsetPerStep * numSteps));

	float prevHeight = 1.0;
	float currRayDist = 1.0;

	while (stepIndex < numSteps) {
		// Determine where along our ray we currently are.
		currRayDist -= stepSize;
		texCurrentOffset -= texOffsetPerStep;
		currHeight = texture(HeightTex, texCurrentOffset).r;

		// Because we're using heights in the [0..1] range
		// and the ray is defined in terms of [0..1] scanning
		// from top-bottom we can simply compare the surface
		// height against the current ray distance.
		if (currHeight >= currRayDist) {
			// Push the counter above the threshold so that
			// we exit the loop on the next iteration
			stepIndex = numSteps + 1;

			// We now know the location along the ray of the first
			// point *BELOW* the surface and the previous point
			// *ABOVE* the surface:
			float rayDistAbove = currRayDist + stepSize;
			float rayDistBelow = currRayDist;

			// We also know the height of the surface before and
			// after we intersected it:
			float surfHeightBefore = prevHeight;
			float surfHeightAfter = currHeight;

			float numerator = rayDistAbove - surfHeightBefore;
			float denominator = (surfHeightAfter - surfHeightBefore)
					- (rayDistBelow - rayDistAbove);

			// As the angle between the view direction and the
			// surface becomes closer to parallel (e.g. grazing
			// view angles) the denominator will tend towards zero.
			// When computing the final ray length we'll
			// get a divide-by-zero and bad things happen.
			float x = 0.0;

			if (abs(denominator) > 1e-5) {
				x = numerator / denominator;
			}

			// Now that we've found the position along the ray
			// that indicates where the true intersection exists
			// we can translate this into a texture coordinate
			// - the intended output of this utility function.

			resultTexPos = mix(texCurrentOffset + texOffsetPerStep, texCurrentOffset, x);
		} else {
			++stepIndex;
			prevHeight = currHeight;
		}
	}

	return resultTexPos;
}

float raymarchShadow(vec2 startPos, vec3 dir) {
	vec2 parallaxDirection = normalize(dir.xy);

	float parallaxLength = sqrt(1.0 - SQR(dir.z));
	parallaxLength /= dir.z;

	vec2 parallaxOffset = parallaxDirection * parallaxLength;
	parallaxOffset *= SteepHeightScale;

	int numSteps = int(mix(MaxSamples, MinSamples, dir.z));

	float currHeight = 0.0;
	float stepSize = 1.0 / float(numSteps);
	int stepIndex = 0;

	vec2 texCurrentOffset = startPos;
	vec2 texOffsetPerStep = stepSize * parallaxOffset;

	float initialHeight = texture(HeightTex, startPos).r + ShadowOffset;

	while (stepIndex < numSteps) {
		texCurrentOffset += texOffsetPerStep;

		float rayHeight = mix(initialHeight, 1.0, stepIndex / numSteps);

		currHeight = texture(HeightTex, texCurrentOffset).r;

		if (currHeight > rayHeight) {
			// ray has gone below the height of the surface, therefore
			// this pixel is occluded...
			return 0.0;
		}

		++stepIndex;
	}

	return 1.0;
}

vec4 steepParallax(vec3 V, vec3 L, vec2 T) {
	vec3 result = vec3(1.0);
	float shadow = 1.0;
	T = raymarch(T, -V);

	if (UseShadow) {
		shadow = raymarchShadow(T, -L);
	}
	vec3 N = getNormal(T);

	return phong(N, V, L, T, shadow);
}
