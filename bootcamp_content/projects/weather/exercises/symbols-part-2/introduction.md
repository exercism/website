# Weather Symbols (Part 2)

In part 2 of this exercise.

This exercise combines all the work you've done so far in the Weather project.

In each scenario, we will use the `draw_weather` function with a weather description.
Your job is to draw the correct weather for that description!

- If it's sunny, draw the sun like you did in the "Sunshine" exercise (without the triangles).
- For all other variants draw the relevant combination of sun, clouds and rain/snow.
- Snow should be the same as rain, but be a circle with a radius of 5.

## Instructions

Your first step is likely to be putting your existing code for "Sunshine" and "Cloud, Rain and Sun" into functions that you can use.

Next you need to create a new function called `draw_weather(description)`.
This will take one string (the description) as an input.

In each scenario, we've given you a different weather situation to draw!

## Reminders

The functions used here are:

- `circle(center_x, center_y, radius)`
- `rectangle(left, top, width, height)`
- `ellipse(center_x, center_y, radius_x, radius_y)`
- `triangle(x1,y1, x2,y2, x3,y3)`
- `fill_color_hex(hex)`
- `fill_color_rgb(red, green, blue)`

The rules of what should be drawn:

- `"sunny"`: `["sun"]`
- `"dull"`: `["cloud"]`
- `"miserable"`: `["cloud", "rain"]`
- `"hopeful"`: `["sun", "cloud"]`
- `"rainbow-territory"`: `["sun", "cloud", "rain"]`
- `"exciting"`: `["cloud", "snow"]`
- `"snowboarding-time"`: `["sun", "cloud", "snow"]`

The drawing details are:

- The sun should be either:
  - `circle(50, 50, 25)` or
  - `circle(75, 30, 15)`
- The cloud should be:
  - `rectangle(25, 50, 50, 10)`
  - `circle(25, 50, 10)`
  - `circle(40, 40, 15)`
  - `circle(55, 40, 20)`
  - `circle(75, 50, 10)`
- The rain should be:
  - `ellipse(30, 70, 3, 5)`
  - `ellipse(50, 70, 3, 5)`
  - `ellipse(70, 70, 3, 5)`
  - `ellipse(40, 80, 3, 5)`
  - `ellipse(60, 80, 3, 5)`
- The snow should be:
  - `circle(30, 70, 5)`
  - `circle(50, 70, 5)`
  - `circle(70, 70, 5)`
  - `circle(40, 80, 5)`
  - `circle(60, 80, 5)`
