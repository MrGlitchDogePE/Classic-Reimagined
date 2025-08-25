#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec2 texCoord0;

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, clamp(uv / 256.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0)));
}

void main() {
    // Apply model offset to position
    vec3 pos = Position + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);

    // Fetch the light map color
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);

    // Fix: Use '==' for comparison and compare against a vec4, not a float
    vec4 targetColor = vec4(229.0 / 255.0, 229.0 / 255.0, 229.0 / 255.0, 1.0);
    if (Color == targetColor) {
        vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
        vertexColor *= 1.223300970873786;
    } else {
        vertexColor = Color * ColorModulator * lightMapColor;
    }

    texCoord0 = UV0;
}
