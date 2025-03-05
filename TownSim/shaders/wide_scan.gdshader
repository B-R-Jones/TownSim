shader_type canvas_item;

// Where the line starts vertically in SCREEN_UV (0..1).
// 0.0 = top, 1.0 = bottom.
uniform float base_y = 1.0;

// The total thickness (in 0..1 screen space) of the line.
uniform float line_thickness = 0.02;

// The line's color
uniform vec4 line_color = vec4(1.0, 0.0, 0.0, 1.0);

// Scroll speed in UV units/second. Positive => line moves upward, negative => downward.
uniform float scroll_speed = 0.1;

// ----------------- GAUSSIAN BUMP -----------------
uniform float bump_amplitude = 0.05;  // vertical offset
uniform float bump_width     = 15.0;  // bigger => broader hump
uniform float bump_speed     = 1.0;   // how fast the bump center travels left→right

void fragment()
{
	float t = TIME;

	//--------------------------------------------------
	// 1) Compute an “unwrapped” scrolled_y
	//    so the line just keeps moving up or down.
	//--------------------------------------------------
	float unwrapped_y = base_y - (t * scroll_speed);

	//--------------------------------------------------
	// 2) We want to allow the line to exist from
	//   -line_thickness..(1.0+line_thickness)
	//   so it fully leaves the screen before re‐entering.
	// Let's define a total range = 1.0 + (line_thickness * 2).
	// Then we wrap unwrapped_y into [ -line_thickness..1.0+line_thickness ].
	//--------------------------------------------------
	float total_range = 1.0 + (line_thickness * 2.0);

	// We'll shift unwrapped_y by line_thickness so 0..(1.0+2*thick) becomes the wrap domain.
	// Then we subtract that shift back after taking fract().
	// This ensures we cycle smoothly in a domain of size total_range.
	float shifted = unwrapped_y + line_thickness;
	// fract() yields [0..1). Multiply by total_range to get [0..total_range).
	// Then shift back by line_thickness to restore the domain to [ -thickness..(1+thickness) ].
	float scrolled_y = fract(shifted / total_range) * total_range - line_thickness;

	//--------------------------------------------------
	// 3) Gaussian bump traveling in X
	//--------------------------------------------------
	float bump_center_x = mod(t * bump_speed, 1.0);
	float dx = SCREEN_UV.x - bump_center_x;
	// Gaussian shape => near dx=0 => big offset, far => 0
	float bump_shape   = exp( - (dx * dx * bump_width) );
	float bump_offset  = bump_shape * bump_amplitude;
	float line_y       = scrolled_y + bump_offset;

	//--------------------------------------------------
	// 4) thickness check
	//--------------------------------------------------
	float dist_to_line = abs(SCREEN_UV.y - line_y);
	if (dist_to_line <= (line_thickness * 0.5))
	{
		COLOR = line_color;
	}
	else
	{
		COLOR = vec4(0.0);
	}
}
