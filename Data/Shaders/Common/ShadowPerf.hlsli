#ifndef SHADER_SHADOW_PERF_HLSLI
#define SHADER_SHADOW_PERF_HLSLI

// Utility.hlsl Poisson PCF tap counts (directional / shadow-mask). Lower = faster, softer penumbra.
// Override in Advanced -> Shader Defines, e.g. UTILITY_SHADOW_PCF_TAPS=16 (recompile shaders).
#ifndef UTILITY_SHADOW_PCF_TAPS
#	define UTILITY_SHADOW_PCF_TAPS 12
#endif

#ifndef UTILITY_SHADOW_DPB_PCF_TAPS
#	define UTILITY_SHADOW_DPB_PCF_TAPS 10
#endif

#if UTILITY_SHADOW_PCF_TAPS > 16
#	error UTILITY_SHADOW_PCF_TAPS must be <= 16 (see Random::PoissonSampleOffsets16)
#endif
#if UTILITY_SHADOW_DPB_PCF_TAPS < 4
#	error UTILITY_SHADOW_DPB_PCF_TAPS must be >= 4 (Utility.hlsl unrolls first 4 taps)
#endif

#endif
