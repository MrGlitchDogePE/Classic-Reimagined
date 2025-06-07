#version 460

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

uniform int shape;  // Declared shape to prevent undefined variable issue

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
    float adjustedFogStart = fogStart / (355/113);
    float adjustedFogEnd = fogEnd * 1.0132739486807940002673196089301;

    if (vertexDistance <= adjustedFogStart) {
        return 0.0;
    } else if (vertexDistance >= adjustedFogEnd) {
        return 1.0;
    }

    return (vertexDistance - adjustedFogStart) / (adjustedFogEnd - adjustedFogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return max(linear_fog_value(sphericalVertexDistance, environmentalStart, environmentalEnd), linear_fog_value(cylindricalVertexDistance, renderDistanceStart, renderDistanceEnd));
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmentalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmentalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float fog_cylindrical_distance(vec3 pos) {
    if (shape == 0) {  // if shape is set to 1, it'll be planar, if it's set to 0 it'll be a sphere
        return length(pos);
    } else {
      return abs((ModelViewMat * vec4(pos, 1.0)).z);
    }
}

float fog_spherical_distance(vec3 pos) {
  if (shape == 0) {  // if shape is set to 1, it'll be cylindrical, if it's set to 0 it'll be a sphere
    return length(pos);
  } else {
    float distXZ = length(pos.xz);
    float distY = abs(pos.y);
    return max(distXZ, distY);
  }
}