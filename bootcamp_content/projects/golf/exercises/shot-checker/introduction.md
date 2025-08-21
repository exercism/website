# Rolling ball

Let's make the golf game a little more interesting! We've given you a new function to use called `get_shot_length()`. This function returns the length of the shot the golfer has hit.

In each scenario, the golfer hits the ball a different length. Click through the `1`, `2`, `3`, `4` boxes to see how far the golfer has hit the ball. Your job is to write code that makes **all the scenarios work**.

## Instructions

You have two things to achieve:

1. Move the ball as far as golfer hits it.
2. If the ball lands over the hole (the shot length is `56`, `57`, `58`, `59`, `60`, `61`, `62` or `63`):
   - Animate the ball dropping down into the hole until its `y` value is `84`
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

Here are a couple of hints. Click on the titles below to expand them.

<details><summary>Hint 1: If you can't work out where to start</summary>

In the previous exercise, you wrote `repeat 61 times do` to make the ball roll to where you needed it.

Wherever you can use a number in code, you can use a variable or the result of a function instead. So that 61 could be a variable or the result of using a function.

You have a function called `get_shot_length()` which returns a different value for each scenario. How can you use it to roll the ball the correct length each time?

</details>

<details><summary>Hint 2: If your ball is rolling one step too few times.</summary>

The result of `get_shot_length()` tells you how many `x` the ball moves **forward.** But that doesn't include the initial animation frame you need to draw the ball on the tee to start with.

So if shot length is `5` and the ball's starting position is `30` (the tee), then if you animate it 5 times, it will draw at `30, 31, 32, 33, 34`. But if you're trying to get to `35` that's not enough!

</details>
