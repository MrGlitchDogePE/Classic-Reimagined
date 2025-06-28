// code by MrGlitchDogePE
// OpenGL Shading Language (GLSL) code for Minecraft shaders
// This code runs with OpenGL version 4.6
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
const int shape = 0; // 0 = spherical, 1 = cylindrical, 2 = planar
// Calculate the fog value based on the distance from the camera
float linear_fog_value(float vertexDistance, float fogStart, float fogEnd) {
  float adjustedFogStart = fogStart / 2.31; // cut-off distance for fog start is 0.85
  float adjustedFogEnd = fogEnd * 1.03;
  if (vertexDistance <= adjustedFogStart) {
    return 0.0;
    } else if (vertexDistance >= adjustedFogEnd) {
      return 1.0;
      } return (vertexDistance - adjustedFogStart) / (adjustedFogEnd - adjustedFogStart);
}

float total_fog_value(float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd) {
    return max(linear_fog_value(sphericalVertexDistance, environmentalStart, environmantalEnd), linear_fog_value(cylindricalVertexDistance, renderDistanceStart, renderDistanceEnd));
}

vec4 apply_fog(vec4 inColor, float sphericalVertexDistance, float cylindricalVertexDistance, float environmentalStart, float environmantalEnd, float renderDistanceStart, float renderDistanceEnd, vec4 fogColor) {
    float fogValue = total_fog_value(sphericalVertexDistance, cylindricalVertexDistance, environmentalStart, environmantalEnd, renderDistanceStart, renderDistanceEnd);
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

// Calculate the distance for fog based on the shape
// Terrain shape is fog_cylindrical_distance
float fog_cylindrical_distance(vec3 pos) {
  if (shape == 0) {
    // Spherical fog distance calculation
    return length(pos);
    } else if (shape == 1) {
      // Cylindrical fog distance calculation
      float distXZ = length(pos.xz);
      float distY = abs(pos.y);
      return max(distXZ, distY);
      } else if (shape == 2) {
        // Planar fog distance calculation
        return abs((ModelViewMat * vec4(pos, 1.0)).z);
        }
}

float fog_spherical_distance(vec3 pos) {
  return length(pos);
}

float fog_planar_distance(vec3 pos) {
    return abs((ModelViewMat * vec4(pos, 1.0)).z);
}

float fog_dithering_distance(vec3 pos) {
    // Dithering distance calculation based on the position
    float ditherScale = 0.1; // Adjust this value for desired dithering effect
    vec2 ditherCoord = mod(pos.xz * ditherScale, 1.0);
    float ditherValue = fract(sin(dot(ditherCoord, vec2(12.9898, 78.233))) * 43758.5453);
    return ditherValue;
}

float fog_sky(vec3 pos) {
    vec3 color1 = vec3(1.0, 0.588, 0.294);   // #FF964B
    vec3 color2 = vec3(0.784, 0.314, 0.196); // #C85032
    vec3 color3 = vec3(0.5, 0.176, 0.176); // #7D2D2D
    vec3 color4 = vec3(0.78, 0.66, 0.5); // #C9AA88
    float tolerance = 0.4;
    if (
        distance(FogColor.rgb, color1) < tolerance ||
        distance(FogColor.rgb, color2) < tolerance ||
        distance(FogColor.rgb, color3) < tolerance ||
        distance(FogColor.rgb, color4) < tolerance
    ) {
      float distXZ = length(pos.xz);
      float distY = abs(pos.y);
      return max(distXZ, distY);
    }
    return length(pos);
}