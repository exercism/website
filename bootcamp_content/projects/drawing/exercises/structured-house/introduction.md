# Structured House

Your task is to use variables to build the house.

Change all the inputs in the functions to use variables.

Set all the variables at the top before the first functions are used. We've set the first few to get you started.

Every variable should either be:

- A number that is specified in the instructions (e.g. the height of the frame); or
- A formula between two variables (e.g. `set roof_left to house_left - roof_overhang`) or a variable and a number specified in the instructions (e.g. `set door_knob_right to door_right - 1`).

Do **not** manually set variables to numbers you've calculated yourself (e.g. DO NOT set `roof_left = 16`)

The purpose of this exercise is get keep pushing you towards structured, ordered thinking. Take your time.

As a reminder, the house should continue to look like this:

<img src="https://assets.exercism.org/bootcamp/graphics/jumbled-house-finished.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

### House Instructions

- The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`.
- The sky fills the canvas (from `0,0` to `100,100`).
- The grass is full width (from `0` to `100`) sits on the bottom of the canvas at `100` with a height of `20`.
- The frame of the house (the big rectangle) should be 60 wide and 40 height. It should have it's top-left corner at 20x50.
- The roof sits snuggly on top of the house's frame. It should overhang the left and right of the house by 4 on each side. It should have a height of 20, and it's point should be centered horizontally (50).
- The windows are both the same size, with have a width of 12 and a height of 13. They both sit 5 from the top of the house frame, and 10 inset from the sides.
- The door is 14 wide and 18 tall, and sits at the bottom of the house in the center.
- The little door knob has a radius of 1, is inset 1 from the right, and is vertically centered in the door.

### Functions

The house uses the following functions:

- `circle(x, y, radius)`
- `rectangle(x, y, width, height)`
- `ellipse(center_x, center_y, radius_x, radius_y)`
- `triangle(x1,y1, x2,y2, x3,y3)`
- `fill_color_hex(hex)`
