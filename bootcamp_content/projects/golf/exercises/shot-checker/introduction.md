# Rolling ball

Let's make the golf game a little more interesting! We've given you a new function to use called `get_shot_length()`. This function returns the length of the shot the golfer has hit.

In each scenario, the golfer hits the ball a different length. Click through the `1`, `2`, `3`, `4` boxes to see how far the golfer has hit the ball. Your job is to write code that makes **all the scenarios work**.

## Instructions

You have two things to achieve:

1. Move the ball as far as golfer hits it.
2. If the ball lands over the hole (the shot length is `56`, `57`, `58`, `59`, `60`, `61`, `62` or `63`):
   - Animate the ball dropping down until into the hole its `y` value is `84`
   - Shoot some fireworks!

## Your Functions

You'll use the following functions to control the game:

- `clear()`
- `circle(center_x, center_y, radius)`
- `fill_color_hex(hex)`
- `get_shot_length()`: Returns a number which is the length of the shot.
- `fire_fireworks()`: Fires off some celebratory fireworks.

You'll also need to use the `set`, `change`, `repeat` and `if` keywords.

The positioning is slightly different from the first exercise:

- The ball has a radius of `3`.
- It sits on the grass at a `y` of `75`.
- It starts on the tee at `30` from the left.

## Hints

### Hint 1

The result of `get_shot_length()` tells you how many `x` the ball moves forward. So if shot length is `5` and the ball's starting position is `30`, then its final position should be `35`, which is `6` frames of animation (30, 31, 32, 33, 34, 35).

### Hint 2

Remember, wherever you can use a number, you can use a variable or the result of a function instead.

e.g. All of these are valid ways to write code (presuming Jiki has the relevant functions on his shelves):

```
circle(1, 2, 3)
circle(x, y, r)
circle(calculate_sun_left(), calculate_sun_width(), calculate_sun_radius())
circle(1, y, calculate_sun_radius())
```
