# The Penguin

Your task is to make the penguin symmetrical.

It should look like this:

<img src="https://assets.exercism.org/bootcamp/graphics/penguin-finished.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`. The penguin is sitting in the middle.

We've drawn the left hand side for you, and added `TODO` comments for each of the things you need to do.

You'll need to think about setting the right colors before drawing things.

For the nose, you should **change** the middle coordinates of the triangle. Don't add a new triangle.

The functions used in this exercise are:

- `circle(center_x, center_y, radius)`
- `rectangle(x, y, width, height)`
- `ellipse(center_x, center_y, radius_x, radius_y)`
- `triangle(x1,y1, x2,y2, x3,y3)`
- `fill_color_hex(hex)`

If you need help remembering how to use any of these functions, you can watch back the video from week 1.
