# Rolling ball

Your task to animate the ball to move ("roll") from the tee on the left to the hole on the right.

Some details:

- The ball has a radius of `3`.
- It sits on the grass at a `y` of `75`.
- It starts on the tee at `30` from the left.

The shot length is how many places it moves forward. So if shot length is `5` and the ball's starting position is `5`, then its final position should be `10`, which is `6` frames of animation (5, 6, 7, 8, 9, 10).

If the shot length is between 56 and 63 inclusively, then the ball drops into the hole. If this happens it should:

- Animate dropping down until it's y value is `84`
- Shoot some fireworks!

You'll use the following functions to control the game:

- `get_shot_length()` which returns a number which is the length of the shot.
- `fire_fireworks()` which fires off some celebratory fireworks.

You'll need to use the following functions to draw things:

- `clear()` (Remember you need to use this at the start of each iteration)
- `circle(center_x, center_y, radius)`
- `fill_color_hex(hex)`

You'll also need to use the `set`, `change`, and `repeat` keywords.

You can use whatever color your like for the ball, but a bright blue might be helpful as it's a little small to see!

- `fill_color_rgb(red, green, blue)`

If you feel stuck or overwhelmed, watch the Level 2 video back.
