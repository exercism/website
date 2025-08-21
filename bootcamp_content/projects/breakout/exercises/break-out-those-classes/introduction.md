# Breakout

This is the final Breakout exercise in Coding Fundamentals.
Your job is to create your own `Block`, `Ball`, `Paddle` and `Game` classes to make the game playable!

## Classes

While all of the game logic is down to you, you have two classes available to use for the drawing part.

### The `Circle` class

The `Circle`'s constructor takes four inputs: `(cx, cy, radius, hex_color)`.

It has a readonly property of `radius` and read/write properties for `cx` and `cy`.

### The `RoundedRectangle` class

The `RoundedRectangle`'s constructor takes six inputs: `(left, top, width, height, radius, hex_color)`. The radius is the corner radius.

It has readonly properties for `top`, `width` and `height`. It has read/write properties for `left` and `opacity`.

### The `game_over` function

You have one game function: `game_over`. It should be called with `"win"` or `"lose"` when the game is won or lost.
The game is won when the final block is smashed. It is lost if the ball hits the floor.

As is often the case you also have the `push` function available.

## Instructions

The code to play the game is given for you. Your job is to implement the classes and methods needed to make it work.

There are a few things you need to stick to in order for the scenario to pass:

- The game's width and height is `100`.
- The paddle should have a width of `20` and a height of `4`. There should be a gap of `1` between it and the floor. It should start in the horizontal middle. You can choose its radius and decide how fast it can move (make it slow to make it more challenging for yourself 😉).
- A row of blocks should be centered with a gap of `1` between each. You can choose their radii. Their opacity is set to `1` by default. It should be changed to `0` once they're hit.
- The ball's radius should be `2`. It should sit on the paddle at its horizontal center. It should move by `1` at a time, starting by moving to the top-left.

You have a huge amount of freedom as to how you design the game.
We explored the first part of this exercise in a live teaching session.
I highly recommend coding along with that to understand the different ways to think about this project, and then continuing to finish the exercise by yourself.

[EMBED](https://www.youtube.com/embed/9QQQB4qctx4)
