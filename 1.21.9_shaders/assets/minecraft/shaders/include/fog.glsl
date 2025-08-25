// Code by MrGlitchDogePE
#moj_import <dynamictransforms.glsl>

layout(std140) uniform Fog {
    vec4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
};

const int shape = 0; // 0 = spherical, 1 = cylindrical, 2 = planar, 3 = experimental

// Linear fog calculation
float linear_fog_value(float distance, float start, float end) {
    float adjustedStart = start / 3.0;
    if (distance <= adjustedStart) return 0.0;
    if (distance >= end) return 1.0;
    return (distance - adjustedStart) / (end - adjustedStart);
}

// Combined fog value from spherical and cylindrical distances
float total_fog_value(float sphericalDist, float cylindricalDist, float envStart, float envEnd, float renderStart, float renderEnd) {
    float envFog = linear_fog_value(sphericalDist, envStart, envEnd);
    float renderFog = linear_fog_value(cylindricalDist, renderStart, renderEnd);
    return max(envFog, renderFog);
}

// Apply fog to color
vec4 apply_fog(vec4 color, float sphericalDist, float cylindricalDist, float envStart, float envEnd, float renderStart, float renderEnd, vec4 fogColor) {
    float fogFactor = total_fog_value(sphericalDist, cylindricalDist, envStart, envEnd, renderStart, renderEnd);
    return vec4(mix(color.rgb, fogColor.rgb, fogFactor * fogColor.a), color.a);
}

// Fog distance based on shape
float fog_cylindrical_distance(vec3 pos) {
    vec4 viewPos = ModelViewMat * vec4(pos, 1.0);
    switch (shape) {
        case 0: return length(pos); // Spherical
        case 1: return max(length(pos.xz), abs(pos.y)); // Cylindrical
        case 2: return abs(viewPos.z); // Planar
        case 3: return max(abs(viewPos.z), length(pos.zx)); // Experimental
        default: return length(pos); // Fallback
    }
}

// Spherical fog distance
float fog_spherical_distance(vec3 pos) {
    return length(ModelViewMat * vec4(pos, 1.0));
}

// Planar fog distance
float fog_planar_distance(vec3 pos) {
    return abs((ModelViewMat * vec4(pos, 1.0)).z);
}
