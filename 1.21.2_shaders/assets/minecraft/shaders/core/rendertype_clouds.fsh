#version 150

/*
MIT License

Copyright (c) 2022 fayer3

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#moj_import <fog_clouds.glsl>

#define MC_CLOUD_VERSION 12102

uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform int FogShape;

in vec3 vertexPosition;
in vec4 vertexColor;

in vec2 xSize1;
in vec2 xSize2;

out vec4 fragColor;

void main() {
    
    // the 9 closest cloud blocks always have all faces those get distortedd, so discard them
    if (xSize1.y > 0 && xSize2.y > 0) {
      if (xSize1.x/xSize1.y - xSize2.x/xSize2.y > 13.0) {
        discard;
      }
    }
    float dist;
    if (FogShape == 0) {
      // sphere fog
      dist = length(vertexPosition);
    } else {
      // cylinder fog
      float distXZ = length(vertexPosition.xz);
      float distY = abs(vertexPosition.y);
      dist = max(distXZ, distY);
    }
    
    fragColor = linear_fog(vertexColor, dist, FogStart, FogEnd, FogColor);
}
