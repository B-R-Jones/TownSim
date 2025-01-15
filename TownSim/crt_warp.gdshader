shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Strength of the barrel distortion (positive = convex CRT style).
uniform float curvature : hint_range(0.0, 0.3) = 0.07;

// How much to darken the edges (0 = none, 1+ = heavy).
uniform float vignette = 0.5;

// Overall color tint/alpha, if you want a slight greenish or bluish CRT look.
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment()
{
	// SCREEN_UV is [0..1] across screen.
	// We'll transform to [-1..1] so we can do a radial distortion.
	vec2 c = SCREEN_UV * 2.0 - 1.0;	// Move from [0..1] to [-1..1]

	// r is the squared distance from center
	float r = dot(c, c);

	// Barrel distortion: bigger curvature => more "bulge"
	c *= 1.0 + curvature * r; 

	// Convert back to [0..1] coords for sampling the screen
	vec2 uv = (c + 1.0) * 0.5;

	// Sample what's behind this rect
	vec4 col = texture(SCREEN_TEXTURE, uv);

	//---------------------------------------
	// VIGNETTE (Darkens corners):
	//---------------------------------------
	// Dist from screen center (0.5, 0.5)
	float dist = length(SCREEN_UV - 0.5);

	// We'll fade from radius = (1.0 - vignette) to 1.0
	// Example: if vignette=0.5, we start darkening at dist=0.5
	float vig = smoothstep(1.0 - vignette, 1.0, dist);

	// The closer dist is to 1.0, the bigger 'vig' => darker corners
	col.rgb *= (1.0 - vig);

	// Apply final tint
	col *= tint_color;

	COLOR = col;
}
