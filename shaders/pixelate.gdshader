shader_type spatial;
render_mode unshaded, depth_draw_always, cull_back, blend_mix;

uniform float pixel_count = 400.0; // number of horizontal pixels
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Calculate pixel size in UVs
    float aspect = float(VIEWPORT_SIZE.x) / float(VIEWPORT_SIZE.y);
    vec2 pixel_size = vec2(1.0 / pixel_count, 1.0 / (pixel_count * aspect));

    // Align UVs to pixel grid
    vec2 coord = floor(SCREEN_UV / pixel_size) * pixel_size + pixel_size * 0.5;

    // Sample screen texture
    vec4 color = textureLod(SCREEN_TEXTURE, coord, 0.0);

    ALBEDO = color.rgb;
    ALPHA = opacity;
}
