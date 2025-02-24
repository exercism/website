# Weather Report

You're now able to take a description of the weather and turn it into a weather symbol, just like you'd find on your favourite weather app.

In this exercise, we're taking that one step further and building out a fuller weather display, show four different weather symbols at once.

Here's an example of what you're aiming for:
<img src="https://assets.exercism.org/bootcamp/graphics/weather-report-completed.png" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

## The four symbols

To achieve this, you need to draw the weather symbols four times, at different scales and different starting positions.

The top symbol should be scaled down to 50% of what you did previously.
It's sky should have a left of 25, a top of 4, and be 50 wide and high.

The other three should all be scaled down to 30%.
The sky in all of them should start with a top of 66, and have widths and heights of 30.

- The first should have a left of 1.
- The second should have a left of 35
- The third should have a left of 69.

All the remaining shapes should be scaled and positioned in accordance to their original sizes and positions in relation to the sky.

We've provided some roughly positioned boxes to help you find your way, but rely on the coordinates above as the truth, not the position of those boxes!

### The data

To use your app, we'll now call the `draw_weather` function with some data from the Meteorological Office.

It is formatted as follows:

```jikiscript
{
  "weather": {
    "now": "snowboarding-time",
    "next": [
      {"time": "07:00", "description": "sunny"},
      {"time": "08:00", "description": "dull"},
      {"time": "09:00", "description": "hopeful"}
    ]
  }
}
```

You need to update your function to use this data as its input and draw the four boxes accordingly.

We've provide your previous code to get you started!

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

The original drawing were are:

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
