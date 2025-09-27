// Nebula shader for SwiftUI (iOS 17+), tuned for dreamy, soft, colorful clouds.
// Uses domain-warped fBm and a palette mapping to purple-cyan hues.

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Utility: hash → [0,1)
inline float hash11(float n) {
    return fract(sin(n) * 43758.5453123);
}

inline float hash12(float2 p) {
    float n = dot(p, float2(127.1, 311.7));
    return fract(sin(n) * 43758.5453123);
}

inline float2 hash22(float2 p) {
    float2 q = float2(dot(p, float2(127.1, 311.7)),
                      dot(p, float2(269.5, 183.3)));
    return fract(sin(q) * 43758.5453123);
}

// Gradient noise (value-like) with smooth interpolation
inline float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);

    float2 g00 = hash22(i + float2(0.0, 0.0)) * 2.0 - 1.0;
    float2 g10 = hash22(i + float2(1.0, 0.0)) * 2.0 - 1.0;
    float2 g01 = hash22(i + float2(0.0, 1.0)) * 2.0 - 1.0;
    float2 g11 = hash22(i + float2(1.0, 1.0)) * 2.0 - 1.0;

    float n00 = dot(g00, f - float2(0.0, 0.0));
    float n10 = dot(g10, f - float2(1.0, 0.0));
    float n01 = dot(g01, f - float2(0.0, 1.0));
    float n11 = dot(g11, f - float2(1.0, 1.0));

    return mix(mix(n00, n10, u.x), mix(n01, n11, u.x), u.y);
}

inline float fbm(float2 p, int octaves, float lacunarity, float gain) {
    float amp = 0.5;
    float freq = 1.0;
    float sum = 0.0;
    for (int i = 0; i < octaves; i++) {
        sum += amp * noise(p * freq);
        freq *= lacunarity;
        amp *= gain;
    }
    return sum;
}

// Color palette mapping (IQ’s cosine palette). Tuned for nebula purple-cyan.
inline float3 palette(float t) {
    // Adjust these to tune the hue band
    float3 a = float3(0.45, 0.38, 0.50);
    float3 b = float3(0.45, 0.45, 0.45);
    float3 c = float3(1.0, 1.0, 1.0);
    float3 d = float3(0.20, 0.35, 0.65); // shifts towards purple/blue/cyan
    return a + b * cos(6.2831853 * (c * t + d));
}

// Star glints: low-density, soft-point highlights with gentle flicker
inline float stars(float2 uv, float time, float density) {
    // Map to a low-res grid
    float2 grid = uv * density;
    float2 id = floor(grid);
    float2 f = fract(grid) - 0.5;
    // Jittered center per cell
    float r = hash12(id + 17.0);
    float2 o = (hash22(id + 19.0) - 0.5) * 0.35;
    float d = length(f - o);
    float base = smoothstep(0.15, 0.0, d - 0.02);
    // Rarity gate
    float rare = step(0.985, r);
    // Flicker
    float flick = 0.75 + 0.25 * sin(time * (3.0 + 4.0 * hash11(r * 91.7)) + r * 12.0);
    return base * rare * flick;
}

// Main nebula shader
// position: pixel position in local coordinates
// size: layer size in points
// time: animation time (seconds)
// seed: different seeds → different patterns
// brightness: overall brightness multiplier (0.0–2.0 typical)
// saturation: color saturation (0.0–2.0 typical)
// alpha: final alpha for compositing (0.0–1.0)
[[ stitchable ]]
half4 nebula(float2 position, float2 size, float time, float seed, float brightness, float saturation, float alpha) {
    // Debug guard: if size not provided (or zero), show green to signal binding issue
    if (min(size.x, size.y) < 1.0) {
        return half4(half3(0.0, 1.0, 0.0), half(alpha));
    }
    // Normalize coordinates to [-1,1], aspect-corrected
    float2 uv = position / size;
    float2 p = uv - 0.5;
    p.x *= size.x / max(size.y, 1.0);

    // Global drift (amplified for clearer motion)
    float2 drift = float2(0.35 * time, -0.28 * time);

    // Scale controls overall pattern size; adjust with screen size to keep feel constant
    float scale = 1.8;
    float2 sp = (p * scale + drift) * 2.5 + seed * 7.3;

    // Domain warp using two fbm fields
    float2 q;
    q.x = fbm(sp + float2(0.0, 0.0), 4, 2.0, 0.55);
    q.y = fbm(sp + float2(5.2, 1.3), 4, 2.0, 0.55);

    float2 r;
    r.x = fbm(sp + 4.0 * q + float2(4.0, 9.0), 4, 2.0, 0.55);
    r.y = fbm(sp + 4.0 * q + float2(1.7, 7.2), 4, 2.0, 0.55);

    float f = fbm(sp + 4.0 * r, 5, 2.0, 0.55);

    // Map density to color via palette
    float t = clamp(0.5 + 0.5 * f, 0.0, 1.0);
    float3 col = palette(t);

    // Emphasize highlights with a soft curve
    float lum = pow(smoothstep(0.15, 1.0, t), 1.2);
    col *= (0.8 + 1.4 * lum);

    // Stars
    float s = stars(uv + seed * 3.7, time, 24.0);
    col += float3(1.0, 1.0, 1.0) * s * 0.75;

    // Saturation control
    float luma = dot(col, float3(0.2126, 0.7152, 0.0722));
    col = mix(float3(luma), col, clamp(saturation, 0.0, 2.0));

    // Vignette and central focus
    float rad = length(p);
    float vignette = smoothstep(0.95, 0.25, rad);
    float focus = smoothstep(0.60, 0.15, rad);
    col *= (0.80 + 0.40 * focus) * vignette;

    // Brightness and final alpha
    col *= clamp(brightness, 0.0, 2.5);
    col = clamp(col, 0.0, 1.0);
    float a = clamp(alpha, 0.0, 1.0);

    return half4(half3(col), half(a));
}
