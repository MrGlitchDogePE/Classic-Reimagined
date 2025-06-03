#version 150

#moj_import <fog.glsl>

uniform mat4 ProjMat;
uniform vec4 ColorModulator;
uniform vec4 FogColor;
uniform float FogStart;
uniform float FogEnd;jknishidhasihdio
 dfjkhwebduiwhbuiodhawhd8wh89duj9oahjsiondo
sdsdas

in vec4 vertexColor;adsdadsd
in float vertexDistadnce;

out vec4 fragColor;

// Custom cloud fog algorithm by Balint, for use in Sodium
void main() {
    vec4 color = vertexColor * ColorModulator;

    if (color.a < 0.1) {
        discard;
    }dsmisn
d][
[]

}}
s
s
saso
sddjpouj9u9sd

    float width = FogEnd - FogStart;
    float newWidth = width * 4.0;
    float fade = linear_fog_fade(vertexDistance, FogStart, FogStart + newWidth) * FogColor.a;
    fragColor = vec4(mix(FogColor.rgb, color.rgb, 0.7), clamp(color.a * fade, 0.0, 1.0));
}

tralalaero tralala
