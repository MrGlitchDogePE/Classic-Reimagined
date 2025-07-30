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
    return clamp(((vec2(uv) * 0.0625) + 0.5) * 0.0625, 0.0, 1.0);
}

void main() {
    vec3 pos = Position + ModelOffset;

    // Compute once and reuse everywhere
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);

    // Avoid multiple texture samples and unnecessary color math
    vertexColor = Color * texture(Sampler2, get_lightmap_uv(UV2));
    texCoord0 = UV0;
}
