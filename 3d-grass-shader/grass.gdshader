shader_type spatial;
render_mode cull_disabled;
render_mode unshaded;

uniform vec3 color : source_color;
uniform vec3 color2 : source_color;
uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	NORMAL = vec3(0.0, 1.0, 0.0);
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * 1.95 + UV.y) * ( 1.0 - UV.y) * 0.35;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * 0.6 + UV.y) * ( 1.0 - UV.y) * 0.15;
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb;
	ALBEDO = mix(color, color2, UV.x) * mix(color, color2, noiseLevel.r);
	
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}