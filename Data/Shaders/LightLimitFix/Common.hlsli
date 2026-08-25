#ifndef __LLF_COMMON_DEPENDENCY_HLSL__
#define __LLF_COMMON_DEPENDENCY_HLSL__

#include "Common/PointLightFalloff.hlsli"

#define NUMTHREAD_X 16
#define NUMTHREAD_Y 16
#define NUMTHREAD_Z 4
#define GROUP_SIZE (NUMTHREAD_X * NUMTHREAD_Y * NUMTHREAD_Z)
#define MAX_CLUSTER_LIGHTS 256

// Forward shaders (Particle, Effect, Water, RunGrass) cap clustered point lights per pixel.
// Deferred BSLightingShader uses DEFERRED_CLUSTERED_LIGHT_CAP (see Lighting.hlsl).
// Defaults are conservative for dense scenes; override with shader defines only if needed.
#ifndef FORWARD_CLUSTERED_LIGHT_CAP
#	define FORWARD_CLUSTERED_LIGHT_CAP 16
#endif

#ifndef DEFERRED_CLUSTERED_LIGHT_CAP
#	define DEFERRED_CLUSTERED_LIGHT_CAP 24
#endif

namespace LightFlags
{
	static const uint PortalStrict = (1 << 0);
	static const uint Shadow = (1 << 1);
	static const uint Simple = (1 << 2);

	static const uint Initialised = (1 << 8);
	static const uint Disabled = (1 << 9);
	static const uint InverseSquare = (1 << 10);
	static const uint Linear = (1 << 11);
}

struct ClusterAABB
{
	float4 minPoint;
	float4 maxPoint;
};

struct LightGrid
{
	uint offset;
	uint lightCount;
	uint pad0[2];
};

struct Light
{
	float3 color;
	float fade;
	float radius;
	float invRadius;
	float fadeZone;
	float sizeBias;
	float4 positionWS;
	uint4 roomFlags;
	uint lightFlags;
	uint shadowLightIndex;
	uint pad0;
	uint pad1;
};

#endif  //__LLF_COMMON_DEPENDENCY_HLSL__