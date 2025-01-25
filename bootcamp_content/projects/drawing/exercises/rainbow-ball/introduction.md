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

The key to this exercise is to do things one at a time:

1. Make the ball change color as it moves
2. Make it bounce off the right hand side
3. Make it bounce off the bottom.
4. Make it bounce randomly

Here are a few hints if you get stuck.
Click the titles to expand.

<details>
<summary>Hint 1: Don't use hard-coded numbers.</summary>

At the start, the ball moves `2` to the right each time.

Remember what we've learnt so far and use a **variable** to store that `2`. Then rather than having `x + 2` have `x + my_variable_name`.

Now ask yourself when that variable should change.

The same applies for `y` and for the `hue`.

</details>

<details>
<summary>Hint 2: Velocity</summary>

What are these numbers that x and y change by?
They're a mixture of speed (the size of the number) and direction (whether it moves the ball forward or back).
So `2` would be a speed of 2 moving to the right or bottom.
And `-3` would be a speed of 3 moving to the left or top.

A number that is a speed and a distance is called a **velocity** (time to update your variable names?)

So when you want to change the direction of the ball, you change the sign of the velocity, from positive to negative or vis-versa.

</details>

<details>
<summary>Hint 3: Randomness</summary>

Hopefully by now you have the ball bouncing.
How do you make it bounce more randomly?

If you're currently changing the velocities by a fixed amount each time, why not change them by a different amount each time using the `random_number` function.

</details>
