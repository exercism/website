# Sunset

Your task is to animate the following scene to make the sun set.

The animation should last `100` iterations and look something like this.

<img src="https://assets.exercism.org/bootcamp/graphics/sunset-frames.png" style="width: 100%; margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

We've drawn the initial scene for you. You need to animate a few things:

- The size of the sun. It should start with a radius of `5` and grow by `0.2` each iteration.
- The position of the sun. It has an initial center of `50, 10`, and should lower in the sky by `1` each iteration.
- The color of the sun from yellow to orange. You can use RGB or HSL. Use a color picker such as [this](https://htmlcolorcodes.com/color-picker/) to find a starting point and ending point you want to animate between.
- The color of the sky. Again, you can use RGB or HSL. It's not possible to animate a true set of sunset colors this way, but be creative and choose something you like.

Remember to `set` the initial values **outside** of the `repeat` block, and then `change` them **inside** the block **before** you call the drawing functions.
If you need a recap on how to animate things, make sure to watch the Level 2 live session back.

The animation will flash a bit. That's expected. We'll learn how to fix that in a future lesson.

The functions used in this exercise are:

- `circle(center_x, center_y, radius)`
- `rectangle(x, y, width, height)`
- `fill_color_rgb(red, green, blue)`
- `fill_color_hsl(hue, saturation, luminosity)`

If you need help remembering how to use any of these functions, you can watch back the video from week 1.

## Remember...

None of the individual things you need to do are hard. But putting them together may feel daunting and unfamiliar. Plan first. Then take each step at a time, and you'll get there. If you need help, please ask on the forum, and remember to give us lots of information about what's not working and why you think that's the case!
