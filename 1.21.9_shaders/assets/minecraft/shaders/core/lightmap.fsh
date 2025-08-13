layout(std140) uniform LightmapInfo {
    float AmbientLightFactor;
    float SkyFactor;
    float BlockFactor;
    int UseBrightLightmap;
    float NightVisionFactor;
    float DarknessScale;
    float DarkenWorldFactor;
    float BrightnessFactor;
    vec3 AmbientColor;
} lightmapInfo;

const float BETA_LIGHT[16] = float[](
    0.0470588235294118,
    0.0627450980392157,
    0.0823529411764706,
    0.1019607843137255,
    0.1254901960784314,
    0.1529411764705882,
    0.1843137254901961,
    0.2196078431372549,
    0.2588235294117647,
    0.3058823529411765,
    0.3647058823529412,
    0.4352941176470588,
    0.5215686274509804,
    0.6352941176470588,
    0.7882352941176471,
    1.0
);

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

    vec3 color = vec3(light_factor);
    color *= (1.0 + lightmapInfo.BrightnessFactor);

    // Apply night vision enhancement
    if (lightmapInfo.NightVisionFactor > 0.0) {
        float max_comp = max(color.r, max(color.g, color.b));
        if (max_comp < 1.0) {
            vec3 boosted = color / max_comp;
            color = mix(color, boosted, lightmapInfo.NightVisionFactor);
        }
    }

    fragColor = vec4(color, 1.0);
}
