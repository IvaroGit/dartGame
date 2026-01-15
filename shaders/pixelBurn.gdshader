shader_type spatial;
render_mode depth_draw_opaque, unshaded, shadows_disabled;

uniform sampler2D noise_tex;
uniform sampler2D albedo_tex;


uniform float fire_alpha = 1.0;               // Transparency
uniform vec2 fire_speed = vec2(0.0, 1.0);    // UV scroll speed
uniform float fire_aperture = 0.22;          // Fire spread
uniform vec4 burn_color = vec4(1.0, 0.0, 0.0, 1.0); // Base fire color


uniform vec2 pixel_size = vec2(0.01, 0.01);

void fragment() {
    // Pixelated UVs
    vec2 shifted_uv = floor(UV / pixel_size) * pixel_size + fire_speed * TIME;

    // Sample fire noise texture
    float fire_noise = texture(noise_tex, shifted_uv).r;

    // Calculate fire intensity
    float noise = UV.y * (((UV.y + fire_aperture) * fire_noise - fire_aperture) * 75.0);

    // Mix burn color with albedo texture based on intensity
    vec4 albedo = mix(burn_color, texture(albedo_tex, UV), clamp(noise, 0.0, 4.0) / 4.0);

    ALPHA = clamp(noise, 0.0, 1.0) * fire_alpha * albedo.a;
    ALBEDO = albedo.rgb;
}
