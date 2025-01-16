# Rolling ball

In this exercise, we introduce some different scenarios for the first time. We've given you a new function to use called `get_shot_length()`. This function gives you the length of the shot the golfer has hit.

Your job is to move the ball that far. Then if the shot length is between `56` and `63` inclusively:

- Animate the ball dropping down until into the hole it's y value is `84`
- Shoot some fireworks!

You'll use the following functions to control the game:

- `clear()`
- `circle(center_x, center_y, radius)`
- `fill_color_hex(hex)`
- `get_shot_length()` which returns a number which is the length of the shot.
- `fire_fireworks()` which fires off some celebratory fireworks.

The positioning is slightly different from the first exercise:

- The ball has a radius of `3`.
- It sits on the grass at a `y` of `75`.
- It starts on the tee at `30` from the left.

You'll also need to use the `set`, `change`, `repeat` and `if` keywords.

### Hints

The result of `get_shot_length()` tells you how many `x` the ball moves forward. So if shot length is `5` and the ball's starting position is `30`, then its final position should be `35`, which is `6` frames of animation (30, 31, 32, 33, 34, 35).
