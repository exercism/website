# Cloud, Rain and Sun

Your task is to draw a weather icon for a rainy day with the sun sneaking out behind the clouds. It should look something like this:

<img src="https://assets.exercism.org/bootcamp/graphics/cloud-rain-sun-finished.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

We've drawn a template for you.
Your shapes should sit just inside the lines.

You'll need to use the following functions to draw things:

- `circle(center_x, center_y, radius)`
- `rectangle(left, top, width, height)`
- `ellipse(center_x, center_y, radius_x, radius_y)`

You can use whatever colors your like for the various components, and you can change color using either of the `fill_color` functions to change color:

- `fill_color_hex(hex)`
- `fill_color_rgb(red, green, blue)`

Remember to set the color before you draw using it.

### Hints

To make things a little easier, nearly all the numbers you need to use are divisible by 5 (e.g. 5, 10, 15, etc). The only exception is the `radius_x` of the raindrops, which is `3`.

You should only use ellipses in the raindrops. If you use them for the sun or clouds, things won't work.

If you need help remembering how to use any of these functions, you can watch back the video from week 1.

### Mindset

This exercise will require lots of trial and error. It's great practice for learning the persistance hacker mindset that we often need as programmers.

However, you should still start by carefully thinking through what needs to done and putting a plan together. Start by thinking what components need to go where, then position each one in turn using the template. You'll need to keep trying and tweaking things to line everything up.
