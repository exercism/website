# Breakout Game

In this exercise, we're going to add blocks into our game and create a fully working game!

This should hopefully feel like a pretty exciting milestone for you!

## Instructions

We're adding two new ideas:

### Blocks

Add three rows of 6 blocks. There should be some space above and below them, and a little gap between each.

If the blocks are hit (top, bottom, left or right) they should disappear (set the `opacity` style property to `0`), and the ball should bounce accordingly. If it hits the left edge, it should bounce back to the left, if it hits the bottom edge, it should bounce back to the bottom, etc.

There are multiple ways to solve this, but you might like to consider using the [`getBoundingClientRect`](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect) method to see if things intersect.

### Winning the game

As soon as the final block is smashed, the game should end with a green success screen (feel free to decorate this, or stick with a basic semi-opaque green!)

## Note

I've set the ball to be a bit to the right in the example game, so that you can see the effects of it hitting the side of the blocks. You might find it helpful to just add one block and change the starting position/speed of the ball to hit it at different examples, as a way of testing your code.

Have fun!
