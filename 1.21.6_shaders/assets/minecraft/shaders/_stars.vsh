#version 150

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;

vec2[] CORNERS = vec2[](
    vec2(-1, 1),
    vec2(-1, -1),
    vec2(1, -1),
    vec2(1, 1)
);

void main() {
  vec4 adjustedModelViewPos = ModelViewMat * vec4(Position, 1.0) + vec4(CORNERS[gl_VertexID % 4] / 3, 0.0, 0.0);
  gl_Position = ProjMat * adjustedModelViewPos;
}
