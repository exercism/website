# Cloud, Rain and Sun

Your task is to draw a weather icon for a rainy day with the sun sneaking out behind the clouds. It should look something like this:

<img src="https://assets.exercism.org/bootcamp/graphics/cloud-rain-sun-finished.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

We've drawn a template for you.
Your shapes should sit just inside the lines.

To make things a little easier, nearly every value is divisible by 5 (e.g. the numbers you'll use are 5, 10, 15, etc). The only exception is the width of the raindrops.

You'll need to use the following functions to draw things:

- `circle(x, y, radius)`
- `rectangle(x, y, height, width)`
- `ellipse(x, y, radius_x, radius_y)`

You can use whatever colors your like for the various components, and you can change color using either of the `fill_color` functions to change color:

- `fill_color_hex(hex)`
- `fill_color_rgb(red, green, blue)`

Remember to set the color before you draw using it.

If you need help remembering how to use any of these functions, you can watch back the video from week 1.
