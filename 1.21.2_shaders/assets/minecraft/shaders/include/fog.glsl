#version 460

vec3 frmHex(int u_color) {
	// by Alex Roth
	float rValue = float(u_color / 256 / 256);
	float gValue = float(u_color / 256 - int(rValue * 256.0));
	float bValue = float(u_color - int(rValue * 256.0 * 256.0) - int(gValue * 256.0));
	return vec3(rValue / 255.0, gValue / 255.0, bValue / 255.0);
}
vec3 frmRgbI(int r, int g, int b) {
	return vec3(r/255,g/255,b/255);
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
	if (distance(inVal.x,target.x)<del &&
	    distance(inVal.y,target.y)<del &&
		distance(inVal.z,target.z)<del) {
		return true;
	} else {
		return false;
	}
}

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    // Weather-based fog logic
    vec3 fogSkyDay = frmHex(0xC0D8FF);
    vec3 fogSkyNight = frmHex(0x000000);

    if (fzyEqlV3(fogColor.rgb, fogSkyDay, 0.4) || fzyEqlV3(fogColor.rgb, fogSkyNight, 0.2)) {
        // Rain or storm: custom fog distances
        fogStart /= 2.31;
        fogEnd *= 1.03;
    } else {
        // Clear weather
        fogStart *= 0;
        fogEnd *= 1.03;
    }
    
    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? (vertexDistance - fogStart) / (fogEnd - fogStart) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

float fog_distance(vec3 pos, int shape) {
    return length(pos);
}
