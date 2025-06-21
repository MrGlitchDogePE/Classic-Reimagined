#version 150

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    // Adjust fogStart and fogEnd based on distance
    fogStart = fogStart / 3.9015697477956056597057791135319;
    fogEnd = fogEnd * 1.1904789743273771115512505500264;

    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;

    // Blend the color and adjust the alpha based on fog
    vec3 blendedColor = mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a);
    float adjustedAlpha = inColor.a * (1.0 - fogValue);

    return vec4(blendedColor, adjustedAlpha);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

float fog_distance(vec3 pos, int shape) {
    if (shape == 0) {
        return length(pos);
    } else {
        float distXZ = length(pos.xz);
        float distY = abs(pos.y);
        return max(distXZ, distY);
    }
}

// Apply fog to terrain
vec4 apply_fog_to_terrain(vec4 terrainColor, vec3 terrainPos, float fogStart, float fogEnd, vec4 fogColor) {
    float distance = fog_distance(terrainPos, 0); // Assuming shape 0 for terrain
    return linear_fog(terrainColor, distance, fogStart, fogEnd, fogColor);
}
