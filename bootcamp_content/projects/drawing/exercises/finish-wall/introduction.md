# Finish the Wall

In the first drawing exercise you completed, you used the `rectangle` and the `fill_color_hex` functions to fill in some gaps in a wall.

In this exercise, we build on that by using the `repeat` keyword to add the top layer to a wall.

The final wall should look like this.
All the layers other than the top one are already complete.
You need to add the final layer of 5 bricks.

<img src="https://assets.exercism.org/bootcamp/graphics/completed-wall.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

Things you need to know:

- Each brick is 10 high and 20 wide.
- The `rectangle` function can only appear once in your code!

### Functions

You need two functions for this exercise:

- `fill_color_hex(hex)`: Changes the color of whatever comes after it
- `rectangle(left, top, width, height)`: Draws a rectangle.
