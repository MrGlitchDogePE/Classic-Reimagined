#version 150

vec3 frmHex(int u_color) {
    // by Alex Roth
    float rValue = float(u_color / 256 / 256);
    float gValue = float(u_color / 256 - int(rValue * 256.0));
    float bValue = float(u_color - int(rValue * 256.0 * 256.0) - int(gValue * 256.0));
    return vec3(rValue / 255.0, gValue / 255.0, bValue / 255.0);
}

vec3 frmRgbI(int r, int g, int b) {
    return vec3(r / 255.0, g / 255.0, b / 255.0);
}

vec3 toHsv(vec3 c) {
    // by Sam Hocevar
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    // by Sam Hocevar
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

bool fzyEqlV3(vec3 inVal, vec3 target, float del) {
    return distance(inVal, target) < del;
}

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    // by shmoobalizer
    float fogLength = fogStart / fogEnd;
    vec4 endFogColor = vec4(frmHex(0x0E0E11), 0.9);

    if (fzyEqlV3(fogColor.rgb, frmHex(0x141014), 0.01)) { // If End Dimension
        fogColor = endFogColor;
    } else if (fogLength > 0.0 && fogLength < 0.2) { // If Nether
        fogStart = fogStart / 3.5384349071477304492426263330319;
        fogEnd = fogEnd * 1.055456748719378155088324506632;
    } else { // If Overworld
        fogStart = fogStart / 3.5384349071477304492426263330319;
        fogEnd = fogEnd * 1.055456748719378155088324506632;
    }

    if (vertexDistance <= fogStart) {
        return inColor;
    }
    
    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    
    // Modify alpha to make objects fully disappear behind the fog
    float alphaFactor = 1.0 - fogValue;

    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a * alphaFactor);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

// 1.18.1 - Cylindrical Fog Distance Calculation
float cylindrical_distance(mat4 modelViewMat, vec3 pos) {
    float distXZ = length((modelViewMat * vec4(pos.x, 0.0, pos.z, 1.0)).xyz);
    float distY = length((modelViewMat * vec4(pos.x, pos.y, pos.z, 1.0)).xyz);
    return max(distXZ, distY);
}

// 1.18.2+ - General Fog Distance Calculation
float fog_distance(mat4 modelViewMat, vec3 pos, int shape) {
    if (shape == 0) {
        return length((modelViewMat * vec4(pos, 1.0)).xyz);
    } else {
        return length((modelViewMat * vec4(pos, 1.0)).xyz);
    }
}
