#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

vec2 get_lightmap_uv(ivec2 uv) {
    // Convert packed 0–255 UV2 values into normalized coordinates
    vec2 normalized = vec2(uv) / 256.0;

    // Snap to texel center to match Vanilla's sampling behavior
    vec2 texel_center = floor(normalized * 16.0) / 16.0 + vec2(0.5) / 16.0;

    // Clamp to valid range (just in case)
    return clamp(texel_center, vec2(0.0), vec2(1.0));
}

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, get_lightmap_uv(uv));
}

void main() {
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
}
