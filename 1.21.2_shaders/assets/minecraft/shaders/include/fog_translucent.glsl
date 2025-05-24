#version 150

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    // Apply adjustments to fogStart and fogEnd
    fogStart = fogStart / 3.594;
    fogEnd = fogEnd * 1.0133;

    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = smoothstep(fogStart, fogEnd, vertexDistance);

    // Make sure that the fade-out is smoother
    vec4 foggedColor = mix(inColor, fogColor, fogValue);
    foggedColor.a = mix(inColor.a, 0.0, fogValue);

    return foggedColor;
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    return smoothstep(fogStart, fogEnd, vertexDistance);
}

float fog_distance(vec3 pos, int shape) {
    if (shape == 1) {
        return length(pos);
    } else {
        float distXZ = length(pos.xz);
        float distY = abs(pos.y);
        return max(distXZ, distY);
    }
}
