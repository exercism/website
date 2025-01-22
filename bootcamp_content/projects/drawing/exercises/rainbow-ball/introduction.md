# Rainbow

Welcome to Rainbow Ball. Your job is to create a ball that randomly bounces around the canvas, drawing a rainbow in its wake!

It should look something like this:

<img src="https://assets.exercism.org/bootcamp/graphics/rainbow-ball.gif" style="width: 100%; max-width:200px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

As part of this exercise, you have a new function called `random_number(min, max)` which returns a random number between the min and max that you input.

Take a few minutes to think through how you could solve this! Remember, this bit is probably the most valuable part of the exercise, so take your time and **write down your ideas before you read the instructions below.** When you've got an idea of your approach, read on!

<hr class="border-borderColor5" style="margin:100px 0"/>

## Instructions

This exercise is all about having some variables that are responsible for the position of the ball, which steadily increase or decrease. And other variables that control **how** the ball is moving and change when certain criteria are met.

### Drawing

- The first circle you draw should be at `(5,5)`.
- All the circles should have a radius of `10`.
- The color of the circle should use HSL, starting with a hue of `100` (green), a saturation of `80` (bold colors), and a luminosity of `50` (mid-brightness).

### Animating

- To start with, in each iteration you should move it `2` to the right and `1` down.
- The hue should increase by `1` each time, until it gets to the maximum (`255`) then start reducing again. The saturation and luminosity don't need to change.

### Bouncing

- Once the ball reaches the edge of the canvas it should change direction. (Check the hints below if you can't work out how to do this).
- To make things more fun you should change direction using the `random_number(min, max)` function, choose `min` and `max` that give the style of animation you want.

## To pass the checks

We've given you a lot of leeway in this exercise. We check that:

- The first few circles are correct
- Over 80% of the canvas gets painted.

The numbers that you choose to achieve that are up to you. You probably want a repeat block that iterates between `500` and `1000` times.

## Functions

The functions used in this exercise are:

- `circle(x, y, radius)`
- `fill_color_hsl(hue, saturation, luminance)`
- `random_number(min, max)`

<hr class="border-borderColor5" style="margin:50px 0"/>

## Hints

At the start you move the circle `2` to the right and `1` down. Think about what these numbers are. They're the **direction** that the ball is moving in. Use variables for them.

Once the ball hits an edge, it needs to change the direction it's moving, so you need to update those direction variables.

The hue works in the same way.
