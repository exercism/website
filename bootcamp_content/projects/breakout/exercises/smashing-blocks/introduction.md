# Breakout

In the last exercise, we got the ball moving around the game frame.
In this exercise we're going to add some blocks!

We've added a new Class called `Block`.
When you create an instance of it, you specify it's left and top position using `new Block(left, top)`.

As soon as you create the block, it will draw on screen.
All blocks are `16` wide.

The block has a `top`, `left`, `width` and `height` properties which you can read. It also has a `smashed` property you can read and write (see below).

## Instructions

You have two tasks.

The first task is to create 5 blocks.
The should all have a top of `31`.
The first should have a left of `8`, and then should be evenly distributed along the game area (which means they have a gap of `1` between them).

The second task is to handle what happens when the ball hits the block.
When this happens the block should have its `smashed` property set to `true` which will cause it to disappear.
The ball should also bounce in the opposite direction.

Once you've hit the final block, you should no longer move the ball (and should just stop running code altogether).

For this exercise (if completed properly), the ball will only ever hit the bottom of the block (which saves you a lot of coding!)

The resulting game should look like this:

<details><summary>Click to expand</summary>

<img src="https://assets.exercism.org/bootcamp/graphics/breakout-smashing-blocks.gif" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>
</details>

### Functions

You have one function available:

- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)
