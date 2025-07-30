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

// Returns normalized and texel-centered lightmap UV
vec2 get_lightmap_uv(ivec2 uv) {
    vec2 normalized = vec2(uv) / 256.0;
    return clamp((floor(normalized * 16.0) + 0.5) / 16.0, vec2(0.0), vec2(1.0));
}

void main() {
    vec3 pos = Position + ModelOffset;
    vec4 worldPos = vec4(pos, 1.0);

    gl_Position = ProjMat * ModelViewMat * worldPos;

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    vertexColor = Color * texture(Sampler2, get_lightmap_uv(UV2));
    texCoord0 = UV0;
}
