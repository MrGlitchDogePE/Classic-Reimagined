#version 460
/*
MIT License

Copyright (c) 2024 fayer3
... [license unchanged] ...
*/

#define MC_CLOUD_VERSION 12106

const float VANILLA_CLOUD_HEIGHT = 192.0;
const float CLOUD_HEIGHT = 108.0;

#moj_import <fog.glsl>
#moj_import <dynamictransforms.glsl>
#moj_import <projection.glsl>

const int FLAG_MASK_DIR = 7;
const int FLAG_INSIDE_FACE = 1 << 4;
const int FLAG_USE_TOP_COLOR = 1 << 5;
const int FLAG_EXTRA_Z = 1 << 6;
const int FLAG_EXTRA_X = 1 << 7;

layout(std140) uniform CloudInfo {
    vec4 CloudColor;
    vec3 CloudOffset;
    vec3 CellSize;
};

uniform isamplerBuffer CloudFaces;

out float vertexDistance;
out vec4 vertexColor;

const vec3[] vertices = vec3[](
    vec3(1, 0, 0), vec3(1, 0, 1), vec3(0, 0, 1), vec3(0, 0, 0),
    vec3(0, 1, 0), vec3(0, 1, 1), vec3(1, 1, 1), vec3(1, 1, 0),
    vec3(0, 0, 0), vec3(0, 1, 0), vec3(1, 1, 0), vec3(1, 0, 0),
    vec3(1, 0, 1), vec3(1, 1, 1), vec3(0, 1, 1), vec3(0, 0, 1),
    vec3(0, 0, 1), vec3(0, 1, 1), vec3(0, 1, 0), vec3(0, 0, 0),
    vec3(1, 0, 0), vec3(1, 1, 0), vec3(1, 1, 1), vec3(1, 0, 1)
);

const vec4[] faceColors = vec4[](
    vec4(0.7, 0.7, 0.7, 0.8),
    vec4(1.0, 1.0, 1.0, 0.8),
    vec4(0.8, 0.8, 0.8, 0.8),
    vec4(0.8, 0.8, 0.8, 0.8),
    vec4(0.9, 0.9, 0.9, 0.8),
    vec4(0.9, 0.9, 0.9, 0.8)
);

void main() {
    int quadVertex = gl_VertexID % 4;
    int index = (gl_VertexID / 4) * 3;

    int cellX = texelFetch(CloudFaces, index).r;
    int cellZ = texelFetch(CloudFaces, index + 1).r;
    int dirAndFlags = texelFetch(CloudFaces, index + 2).r;
    int direction = dirAndFlags & FLAG_MASK_DIR;
    bool isInsideFace = (dirAndFlags & FLAG_INSIDE_FACE) == FLAG_INSIDE_FACE;

    bool belowNewClouds = (VANILLA_CLOUD_HEIGHT - CloudOffset.y) < CLOUD_HEIGHT;
    bool belowClouds = CloudOffset.y > 0;
    bool aboveNewClouds = (VANILLA_CLOUD_HEIGHT - CloudOffset.y - 4) > CLOUD_HEIGHT;
    bool aboveClouds = CloudOffset.y + 4 < 0;

    if (direction == 0 && aboveNewClouds && belowClouds) {
        direction = 1;
    } else if (direction == 1 && belowNewClouds && aboveClouds) {
        direction = 0;
    }

    bool useTopColor = (dirAndFlags & FLAG_USE_TOP_COLOR) == FLAG_USE_TOP_COLOR;
    cellX = (cellX << 1) | ((dirAndFlags & FLAG_EXTRA_X) >> 7);
    cellZ = (cellZ << 1) | ((dirAndFlags & FLAG_EXTRA_Z) >> 6);

    vec3 faceVertex = vertices[(direction * 4) + (isInsideFace ? 3 - quadVertex : quadVertex)];
    vec3 pos = (faceVertex * CellSize) + (vec3(cellX, 0, cellZ) * CellSize) + CloudOffset
             - vec3(0, VANILLA_CLOUD_HEIGHT - CLOUD_HEIGHT, 0);

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    vertexDistance = fog_spherical_distance(pos);

    // Override CloudColor with its grayscale version
    float luminance = dot(CloudColor.rgb, vec3(0.299, 0.587, 0.114));
    vec4 grayCloudColor = vec4(vec3(luminance), CloudColor.a);

    vertexColor = (useTopColor ? faceColors[1] : faceColors[direction]) * grayCloudColor;
}
