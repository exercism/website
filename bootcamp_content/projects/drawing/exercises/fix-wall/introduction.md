# Fix the Wall

The exercise introduces you to the `rectangle` and `fill_color_hex` functions.

### Drawing Rectangles

To draw rectangles, we use the `rectangle` function with 4 inputs:

- `left`: The left side of the rectangle
- `top`: The top of the rectangle
- `width`: How wide the rectangle is
- `height`: How high the rectangle is

<img src="https://assets.exercism.org/bootcamp/graphics/intro-rectangle.jpg" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

### Changing colors

You can use the `fill_color_hex(color)` function to set the color of something.
The input is always a string and can either be a hex color (e.g. `"#ff0000"`) or an HTML Color (e.g. `"red"`).

You need to use that function every time you want to **change** the color, before you draw the shape.
The color then stays the same for future shapes until you change it again.

## Instructions

In this exercise, your job is to use three brick-colored rectangles to fill the holes in the wall.

You can check [HTML Color Codes](https://htmlcolorcodes.com/colors/brick-red/) to find a good hex code for the color of the bricks.
Remember to input it as a string.

The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`. You can hover over the canvas if you want to check where something needs to go.

To make your life easier, the top, left, height and widths are all divisible by 10.

If you need help remembering how to use any of these functions, you can watch back the video from week 1.
