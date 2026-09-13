#version 460

#moj_import <minecraft:fog.glsl>

in float vertexDistance;
in vec4 vertexColor;
out vec4 fragColor;

void main() {
    vec4 color = vec4(1.0, 1.0, 1.0, vertexColor.a);
    color.rgb *= mix(vertexColor.rgb, FogColor.rgb, total_fog_value(vertexDistance, vertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd));
    color.a *= sqrt(1.0f - pow(classic_fog_value(vertexDistance, 0, FogCloudsEnd), 2));
    // fog color calculation
    // alpha calculation
    // if the fog is fully opaque, use the fog color, otherwise use the vertex color
    fragColor = color;
}