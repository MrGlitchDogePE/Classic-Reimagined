#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;

const vec2 CORNERS[4] = vec2[](vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(1.0, 1.0), vec2(-1.0, 1.0));

void main() {
    vec4 adjustedModelViewPos = ModelViewMat * vec4(Position, 1.0) + vec4(CORNERS[gl_VertexID % 4] / 3, 0.0, 0.0);
    gl_Position = ProjMat * adjustedModelViewPos;
}
