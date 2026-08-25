#ifndef POINT_LIGHT_FALLOFF_HLSLI
#define POINT_LIGHT_FALLOFF_HLSLI

// Vanilla-style falloff uses 1 - (d/r)^2; at gameplay radius the cut feels like a hard pool edge.
// Attenuation-only scale >1 softens the visible boundary (torches, moving lights). Does not change cluster culling.
// Override via Advanced -> Shader Defines: POINT_LIGHT_FALLOFF_RADIUS_SCALE=1.0 restores vanilla shaping.
#ifndef POINT_LIGHT_FALLOFF_RADIUS_SCALE
#	define POINT_LIGHT_FALLOFF_RADIUS_SCALE 1.11
#endif

#endif
