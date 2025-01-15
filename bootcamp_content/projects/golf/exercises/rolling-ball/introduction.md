# Rolling ball

Your task to animate the ball to move ("roll") from the tee on the left to the hole on the right.

Some details:

- The ball has a radius of `3`.
- It sits on the grass at a `y` of `75`.
- It starts on the tee at `28` from the left.
- It should roll until it is `88` from the left
- It should move by 1 each `repeat` block

You'll need to use the following functions to draw things:

- `clear()` (Remember you need to use this at the start of each iteration)
- `circle(center_x, center_y, radius)`
- `fill_color_hex(hex)`

You'll also need to use the `set`, `change`, and `repeat` keywords.

You can use whatever color your like for the ball, but a bright blue might be helpful as it's a little small to see!

- `fill_color_rgb(red, green, blue)`

If you feel stuck or overwhelmed, watch the Level 2 video back.

### Hints

Remember that if you update the position at the **start** of the `repeat` block, then the value that's put into the `circle` function in the first iteration will be one greater than whatever you set the initial value too.

Use the scrubber (the play bar at the bottom left) to check the value of x if you're not clear on what's happening. Click on the little toggle button to see information on each line!
