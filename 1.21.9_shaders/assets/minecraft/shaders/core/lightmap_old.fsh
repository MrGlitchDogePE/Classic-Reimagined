#moj_import <betalight.glsl>

layout(std140) uniform LightmapInfo {
    float AmbientLightFactor;
    float SkyFactor;
    float BlockFactor;
    float NightVisionFactor;
    float DarknessScale;
    float DarkenWorldFactor;
    float BrightnessFactor;
} lightmapInfo;

in vec2 texCoord;
out vec4 fragColor;

int spread(float f, int x) {
    return clamp(int(floor(f * float(x + 1))), 0, x);
}

void main() {
    int block_light = spread(texCoord.x, 15);
    int sky_light = spread(texCoord.y, 15);
    int sky_factor = clamp(spread(1.0 - lightmapInfo.SkyFactor, 15), 0, 11);

    // Subtract sky_factor from sky_light and clamp the result
    int adjusted_sky = clamp(sky_light - sky_factor, 0, 15);

    // Use the higher value between block light and adjusted sky light
    int final_index = max(block_light, adjusted_sky);
    float light_factor = BETA_LIGHT[final_index];

    vec3 color = vec3(light_factor / 255);

    // Apply night vision enhancement
    if (lightmapInfo.NightVisionFactor > 0.0) {
        float max_comp = max(color.r, max(color.g, color.b));
        if (max_comp < 1.0) {
            vec3 boosted = color / max_comp;
            color = mix(color, boosted, lightmapInfo.NightVisionFactor);
        }
    }
    // Apply brightness factor
    fragColor = pow(vec4(color, 1.0), vec4(1.0 / (1.0 + lightmapInfo.BrightnessFactor)));
}
