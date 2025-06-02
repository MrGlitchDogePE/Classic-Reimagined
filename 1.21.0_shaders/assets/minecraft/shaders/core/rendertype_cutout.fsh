#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float time; // Added time uniform for animation

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

// Function to create a higher-resolution dynamic dithering matrix based on time
mat4 getDynamicDitherMatrix(float time) {
    float phase = mod(time * 0.05, 1.0); // Adjust phase speed for more dynamic changes
    float freq = mod(time * 0.02, 1.0); // Additional frequency to vary dithering
    return mat4(
        0.0 + phase, 0.25 + phase + freq, 0.5 + phase, 0.75 + phase + freq,
        0.75 + phase, 0.5 + phase + freq, 0.25 + phase, 0.0 + phase + freq,
        0.5 + phase, 0.75 + phase + freq, 0.0 + phase, 0.25 + phase + freq,
        0.25 + phase, 0.0 + phase + freq, 0.75 + phase, 0.5 + phase + freq
    );
}

// Enhanced noise function with higher frequency and gradient blending
float smoothNoise(vec2 uv) {
    uv = uv * 0.1 + vec2(time * 0.05, time * 0.03); // Animate noise with time
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453); // Base noise
    float gradient = smoothstep(0.0, 1.0, uv.x); // Gradient-based adjustment
    return mix(noise, gradient, 0.5); // Blend noise with gradient
}

// Function to generate a higher-resolution dithering pattern
float highResDither(vec2 uv, float time) {
    vec2 ditherCoord = mod(uv * 4.0 + vec2(time * 0.1, time * 0.1), 1.0); // Higher resolution pattern
    float ditherValue = fract(sin(dot(ditherCoord, vec2(12.9898, 78.233))) * 43758.5453); // Noise-based dither
    return ditherValue;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    
    if (color.a < 0.5) {
        discard;
    }
    
    mat4 dither = getDynamicDitherMatrix(time); // Get the dynamic dithering matrix
    vec2 fragCoord = gl_FragCoord.xy;
    float ditherValue = dither[int(mod(fragCoord.x, 4.0))][int(mod(fragCoord.y, 4.0))];
    
    // Add smoothed noise with gradient blending
    float noiseValue = smoothNoise(texCoord0 * 20.0 + vec2(time * 0.1)); // Adjust scale for desired noise level
    
    // Generate a higher-resolution dithering pattern
    float highResDitherValue = highResDither(texCoord0, time);
    
    // Calculate fog value with smooth transition
    float fogValue = smoothstep(FogStart, FogEnd, vertexDistance);
    
    // Apply dithering, smoothed noise, and fog effect
    float blendedValue = fogValue * fogValue + ditherValue + noiseValue * 0.1 + highResDitherValue * 0.1 - 0.0625;
    
    if (blendedValue >= 1.0) {
        discard;
        return;
    }
    
    // Blend the color with fog color based on fog factor
    vec4 finalColor = mix(color, FogColor, fogValue);
    fragColor = linear_fog(finalColor, vertexDistance, FogStart, FogEnd, FogColor);
}
