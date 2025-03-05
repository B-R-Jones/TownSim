shader_type canvas_item;

// Existing scan-line properties
uniform float line_thickness = 1.0;
uniform float line_gap       = 2.0;
uniform vec4  line_color     = vec4(1.0, 0.0, 0.0, 1.0);

// New properties for scrolling + warping
// Scrolling speed: how many pixels per second the lines move downward.
uniform float scroll_speed   = 30.0; 
// Warp strength: how many pixels to shift left/right at peak of wave.
uniform float warp_strength  = 0.0;
// Warp frequency: wave cycles per screen pixel on the Y axis.
uniform float warp_frequency = 0.0;
// Warp speed: how fast the wave oscillates over time.
uniform float warp_speed     = 0.5;

void fragment()
{
	// line_period = total cycle size for one line + gap
	float line_period = line_thickness + line_gap;

	// Built-in TIME in Godot (in seconds since the game started).
	// If your build doesn't have TIME for canvas_item shaders,
	// you can replace it with a custom uniform float passed from script.
	float t = TIME;

	// 1) SCROLLING:
	// We'll shift FRAGCOORD.y by (t * scroll_speed) so lines move over time.
	float y_scroll = FRAGCOORD.y + (t * scroll_speed);

	// 2) WARPING:
	// We'll offset by a sine wave based on Y, so the lines wobble horizontally.
	float x_warp = sin(FRAGCOORD.y * warp_frequency + t * warp_speed) * warp_strength;

	// Combine scroll + warp into the final "Y" coordinate for the line calculation.
	float y_mod = mod(y_scroll - 20.0, line_period);

	// If within line_thickness, draw the line color, else transparent.
	if (y_mod < line_thickness)
	{
		COLOR = line_color;
	}
	else
	{
		COLOR = vec4(0.0);
	}
}
