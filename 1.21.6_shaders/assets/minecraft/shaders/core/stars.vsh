#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;

const vec2 CORNERS[4] = vec2[](vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(1.0, 1.0), vec2(-1.0, 1.0));

void main() {
    vec4 mvPos = ModelViewMat * vec4(Position, 1.0);
    float scale = DESIRED_SIZE; // e.g., 0.05, tweak as needed
    vec2 offset = CORNERS[gl_VertexID % 4] * scale;
    offset /= mvPos.z; // scale by depth to keep size constant in screen space
    vec4 adjustedModelViewPos = mvPos + vec4(offset, 0.0, 0.0);
    gl_Position = ProjMat * adjustedModelViewPos;
}
