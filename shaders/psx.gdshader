shader_type spatial;
render_mode skip_vertex_transform, vertex_lighting, diffuse_lambert, specular_disabled;

global uniform float psx_enabled;

uniform sampler2D albedo_tex : source_color, filter_nearest, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float snap_res = 120.0; //Change this to a higher number for more wobble

varying vec3 uvw;

void vertex() {
    vec3 view_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    NORMAL = normalize((MODELVIEW_NORMAL_MATRIX * NORMAL));
    VERTEX = view_pos;

    vec4 clip = PROJECTION_MATRIX * vec4(view_pos, 1.0);

    // Vertex snapping
    vec4 snapped = clip;
    snapped.xyz /= snapped.w;
    snapped.xy = floor(snapped.xy * snap_res) / snap_res;
    snapped.xyz *= snapped.w;
    POSITION = mix(clip, snapped, psx_enabled);

    // Affine texture mapping
    uvw = vec3(UV * clip.w, clip.w);
}

void fragment() {
    vec2 uv = mix(UV, uvw.xy / uvw.z, psx_enabled);
    ALBEDO = texture(albedo_tex, uv).rgb * tint.rgb;
}