#version 150

/*
#version 150

/*
MIT License

Copyright (c) 2024 fayer3

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

#define MC_CLOUD_VERSION 12102

const float VANILLA_CLOUD_HEIGHT = 192.0;

const float CLOUD_HEIGHT = 108.0;

in vec3 Position;
in vec4 Color;

uniform vec4 ColorModulator;
uniform mat4 ModelViewMat;
uniform vec3 ModelOffset;
uniform mat4 ProjMat;

out vec3 vertexPosition;
out vec4 vertexColor;
out vec2 xSize1;
out vec2 xSize2;

void main() {
    xSize1 = vec2(0);
    xSize2 = vec2(0);
    vertexColor = Color * ColorModulator;
    vec3 pos = Position;
    
    bool belowNewClouds = (VANILLA_CLOUD_HEIGHT - ModelOffset.y) < CLOUD_HEIGHT;
    bool belowClouds = ModelOffset.y > 0;
    
    bool aboveNewClouds = (VANILLA_CLOUD_HEIGHT - ModelOffset.y - 4) > CLOUD_HEIGHT;
    bool aboveClouds = ModelOffset.y + 4 < 0;
    
    bool up = distance(Color.rgb, vec3(1.0)) < 0.005;
    bool down = distance(Color.rgb, vec3(0.69804)) < 0.005;
    
    // need to invert the cloud quads, because backface culling is on
    if (aboveNewClouds && down && belowClouds) {
      switch (gl_VertexID % 4) {
        case 0:
          pos += vec3(-12, 0, 12);
          xSize2 = vec2(pos.x, 1);
          break;
        case 2:
          pos += vec3(12, 0, -12);
          xSize1 = vec2(pos.x, 1);
          break;
      }
      pos.y += 4;
      // brighten them up to be as bright as the original top
      vertexColor.rgb *= 1.43258266;
    } else if (belowNewClouds && up && aboveClouds) {
      switch (gl_VertexID % 4) {
        case 0:
          pos += vec3(12, 0, 12);
          xSize1 = vec2(pos.x, 1);
          vertexColor.rgb += vec3(0,1,0);
          break;
        case 2:
          pos += vec3(-12, 0, -12);
          xSize2 = vec2(pos.x, 1);
          break;
      }
      pos.y -= 4;
      // brighten them up to be as dark as the original bottom
      vertexColor.rgb *= 0.69804;
    }
    
    vertexPosition = vec3(pos.x, pos.y + (CLOUD_HEIGHT-VANILLA_CLOUD_HEIGHT), pos.z) + ModelOffset;
    gl_Position = ProjMat * ModelViewMat * vec4(vertexPosition, 1.0);
}
