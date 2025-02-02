# Build the Wall

Last time you saw the wall, you added a top layer to it.

In this exercise, we build on that by adding **lots** of bricks (55 in total) to build a wall from scratch.

The final wall should look like this:

<img src="https://assets.exercism.org/bootcamp/graphics/completed-wall.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

Things you need to know:

- **Every** brick is 10 high and 20 wide.
- The rows alternate between starting at the left edge, and starting off-screen to the left.
- The `rectangle` function can only appear once in your code!

The aim of this exercise is for you to experiment with using `repeat` blocks and potentially use `functions`.
There are **lots** of different ways to solve this exercise, and there is no right or wrong way.
Your challenge is to solve it in a way that you feel results in as clean and satsifying code as you can achieve.

### Functions

You need two functions for this exercise:

- `fill_color_hex(hex)`: Changes the color of whatever comes after it
- `rectangle(left, top, width, height)`: Draws a rectangle.
