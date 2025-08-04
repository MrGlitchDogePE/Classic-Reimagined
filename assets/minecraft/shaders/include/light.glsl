#version 460

#define MINECRAFT_LIGHT_POWER   (0.6)
#define MINECRAFT_AMBIENT_LIGHT (0.4)

vec4 minecraft_mix_light(vec3 lightDir0, vec3 lightDir1, vec3 normal, vec4 color) {
    float light0 = max(0.0, dot(lightDir0, normal));
    float light1 = max(0.0, dot(lightDir1, normal));
    float lightAccum = min(1.0, (light0 + light1) * MINECRAFT_LIGHT_POWER + MINECRAFT_AMBIENT_LIGHT);
    return vec4(color.rgb * lightAccum, color.a);
}

// Final Vanilla-style texel-center sampling with optimized precision
vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    // Treat UVs as raw packed 0–255 values
    const float GRID_RES = 16.0;
    const vec2 INV_ATLAS_SIZE = vec2(1.0 / 256.0); // Avoid division each time

    // Normalize and center inside texel grid
    vec2 normalized = vec2(uv) * INV_ATLAS_SIZE;
    vec2 snapped = (floor(normalized * GRID_RES) + 0.5) / GRID_RES;

    // Clamp to prevent out-of-bounds sampling (especially near edges)
    return texture(lightMap, clamp(snapped, vec2(0.0), vec2(1.0)));
}
