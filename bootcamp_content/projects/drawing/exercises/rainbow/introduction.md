# Rainbow

Your task is to make a beautiful rainbow like this:

<img src="https://assets.exercism.org/bootcamp/graphics/rainbow-finished.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

The rainbow is made up of lots of bars.

**Before reading any more of the instructions**, take a few minutes to work out conceptually how to achieve this. Write down the steps you think you need to follow on a piece of paper.

**Once you've got a solution** you're happy with (or given up), **scroll down** to see the instructions...

<hr class="border-borderColor5" style="margin:80px 0"/>

## How to solve it...

- The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`.
- The rainbow is made up of `100` bars, each with a width of `1`, starting at the top (`0`) and being `100` high.
- The first bar should have an `x` of 0, and the final bar should have an `x` of 99.
- You will need a variable for `x`. When choosing its initial value, remember that it will be increased in the `repeat` block BEFORE drawing.
- You also need a variable for the `hue` of the color (set initially to `0`)
- You need to write a repeat loop that repeats 100 times.
- In each iteration of the repeat loop you need to increase `x` by 1 and increase the hue by `3`.
- You then need to use the `fill_color_hsl` (with saturation and luminance set around 50), and `rectangle` functions to draw.

Use the scrubber (the play bar at the bottom right) and the toggle switch next to it to check the inputs that are going into the functions.

The functions used in this exercise are:

- `rectangle(x, y, width, height)`
- `fill_color_hsl(hue, saturation, luminance)`

If you need help remembering how to use any of these functions, you can watch back the video from week 1. If you need help with variables or animation, watch back the video from week 2!
