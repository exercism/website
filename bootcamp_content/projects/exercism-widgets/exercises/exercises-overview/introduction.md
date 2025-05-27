# Exercises Overview Sample

In this exercise you're going to recreate the top of a track page, which shows an overview of your progress through all the exercise so far.

## Instructions

Firstly, ensure that you can see all the elements of the target. You might need to zoom out a little to do this. It should look like the image below. It doesn't matter if it's a little different on your screen as long as you can see all the elements.

<img src="https://assets.exercism.org/bootcamp/graphics/exercises-overview-sample.png" style="width: 100%; max-width:300px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

### Properties

You can use whatever properties you feel are appropriate to solve this exercise.

Here's some notes:

- All sizes are pixels, except for the progress of the progress bar, border-sizes and border-radiuses. Except for font-sizes they are all divisible by 5.
- The percentage in the heading is colored `#604FCD`.
- The JavaScript logo is at `/bootcamp/images/javascript-tight.svg`.
- There are three circles.
  - The white circle means the exercise is available. It has a `1px` border of `#aaa`.
  - The blue circle means the exercise is in progress. It has a background of `#6A93FF` and a `1px` border of `#2E57E8`.
  - The completed circle uses an image from `/bootcamp/images/check-circle.svg`. I used a background image set to `contain`. It has no border.
- The progress bar's background color is `#E1EBFF`.
- The progress bar has a gradient. You can set this using the following property:

```css
background: linear-gradient(to right, #2200ff 0%, #9e00ff 100%);
```
