# Breakout

In the last exercise, we got the ball moving around the game frame.
In this exercise we're going to add some blocks!

We've added a new Class called `Block`.
When you create an instance of it, you specify it's left and top position using `new Block(left, top)`.

As soon as you create the block, it will draw on screen.
All blocks are `16` wide and `7` high.

## Instructions

You have two tasks.

The first task is to create 5 blocks.
The should all have a top of `31`.
The first should have a left of `8`, and then should be evenly distributed along the game area (which means they have a gap of `1` between them).

The second task is to handle what happens when the ball hits the block.
When this happens the block should have its `smashed` property set to `true` which will cause it to disappear.
The ball should also bounce in the opposite direction.

Once you've hit the final block, you should no longer move the ball (and should just stop running code altogether).

A couple of notes:

- For this exercise (if completed properly), the ball will only ever hit the bottom of the block (which saved you a lot of coding!)
- As a reminder, the ball has a radius of `3` (a diameter of `6`).

### Functions

You have one function available:

- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)
