# Breakout

Welcome to the third Breakout exercise.
There's a few changes for you in this one!

### The `Game` class

Firstly, you now have a `Game` class.
This has three readonly properties:

- `ball`: The ball
- `blocks`: The blocks
- `paddle`: The paddle.

You also have two methods:

- `add_block(block)`: Adds a block to the game.
- `game_over(result)`: Ends the game (expects the input to be either `"win"` or `"lose"`).

### The `Paddle` class

The game's `paddle` is an instance of the `Paddle` class.
This has various readonly properties:

- `cx`: The center x of the paddle.
- `cy`: The center y of the paddle.
- `height`: The height of the paddle.
- `width`: The width of the paddle.

It also has two methods:

- `move_left()`: Move the paddle left.
- `move_right()`: Move the paddle right.

Note that the paddle moves slightly slower than the ball! And it moves slower when moving left then when moving right 😮

### The `Ball` class

Previously you used the `move_ball(ball)` function to move the ball. Now you should use the ball's `move()` method instead.

### The `Block` class

The Block class is unchanged. You create a block by specifying a left and top into the constructor.

## Instructions

There are a few steps to take:

1. Amend your code to use an instance of the `Game` class. When you create an instance of the `Game` class, the ball and the paddle are automatically created and available. You still need to create the `Block` instances like you did previously, but now you need to add them to the game for them to appear.
2. You need to change the `top` of the blocks to be `28`, not `31`.
   and handle the paddle.
3. You need to handle hitting the tops of the blocks as well as the bottom.
4. You need to implement the paddle.

Because the paddle travels slower than the ball, you need to be a little more intelligent than just trying to follow the ball with the paddle. You **cannot** move the paddle twice in a row before moving the ball. It's a fun problem to solve, but if you get too frustrated, check the hint!

The resulting game should look like this:

<details><summary>Click to expand</summary>

<img src="https://assets.exercism.org/bootcamp/graphics/breakout-paddle.gif" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>
</details>

### Functions

You have one function available:

- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)

## Hints

Stuck on the paddle? Expand to get the solution...

<details><summary>Click to expand</summary>

The secret with the paddle is to move it back to the center when the ball is rising and then follow the ball once it's on its way back down.

</details>
