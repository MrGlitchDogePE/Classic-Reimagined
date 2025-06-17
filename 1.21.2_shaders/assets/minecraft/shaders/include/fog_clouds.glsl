#version 460

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    if (vertexDistance <= fogStart) {
        return inColor;
    }

    // Compute normalized fog value with clamping
    float fogValue = clamp((vertexDistance - fogStart) / (fogEnd - fogStart), 0.0, 1.0);

    // Blend colors and fade out alpha for full transparency in the distance
    vec3 finalColor = mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a);
    float alphaFade = 1.0 - fogValue;
    return vec4(finalColor, inColor.a * alphaFade);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    // Smooth fading from full visibility to full fog
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

float fog_distance(vec3 pos, int shape) {
    // Currently using simple Euclidean distance
    return length(pos);
}
