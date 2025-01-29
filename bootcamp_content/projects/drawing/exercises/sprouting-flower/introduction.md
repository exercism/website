# Sprouting Flower

Your task is to make a flower that grows.

The animation should last `60` iterations and look something like this.

<img src="https://assets.exercism.org/bootcamp/graphics/sprouting-flower-frames.png" style="width: 100%; margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

The key to this exercise is to build relationships between the different elements. This is a key skill in programming.

**Before reading any more of the instructions**, take a few minutes to work out conceptually how to achieve this. Write down the steps you think you need to follow on a piece of paper.

**Once you've got a solution** you're happy with (or given up), **scroll down** to see the instructions...

<hr class="border-borderColor5" style="margin:80px 0"/>

## How to solve it...

The key component of this is the center of the flower. Everything else can be calculated off that center point. On each iteration of the loop, the center point should move up by `1` (before drawing).

Here are some other things you need to know:

- The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`.
- The radius of the flower starts at `0` and should increase by `0.4` on each iteration (before drawing)
- The radius of the pistil (the middle yellow bit of the flower) starts at `0` and should increase by `0.1` on each iteration (before drawing).
- The stem should start at the center of the flower and reach the ground.
- The stem's width is 10% of the stem's height (so `stem_height / 10`).
- Everything is centered on the horizontal axis.
- The leaves sit flush against the stalk on each side.
- The leaves sit half way down the stem.
- The `x_radius` of the leaves is 50% the radius of the flower.
- The `y_radius` of the leaves is 20% of the radius of the flower.

The functions you'll use are:

- `circle(center_x, center_y, radius)`
- `ellipse(center_x, center_y, radius_x, radius_y)`
- `rectangle(x, y, width, height)`
- `fill_color_hex(hex)`

It is **essential** to work on one thing at a time:

- Start by drawing the pink flower and getting it to move up.
- Then get it to grow.
- Add the smaller yellow center..
- Add the stem.
- Add the left leaf.
- Add the right leaf.

Use the scrubber bar to scroll through the code and work out where things are going wrong.

### The final flower

If something's not working, here are some values you can check against (toggle the switch on the scrubber bar to get information):

First drawn flower:

- Flower: `circle(50, 89, 0.4)`
- Pistil: `circle(50, 89, 0.1)`
- Stem: `rectangle(49.95, 89, 0.1, 1)`
- Left leaf: `ellipse(49.75, 89.5, 0.2, 0.08)`
- Right leaf: `ellipse(50.25, 89.5, 0.2, 0.08)`

Final drawn flower:

- Flower: `circle(50, 30, 24)`
- Pistil: `circle(50, 30, 6)`
- Stem: `rectangle(47, 30, 6, 60)`
- Left leaf: `ellipse(35, 60, 12, 4.8)`
- Right leaf: `ellipse(65, 60, 12, 4.8)`

### This is a tough exercise!

This is a challenging exercise. Take your time, and if you get really stuck, ask for help on the forum, and remember to give us lots of information about what's not working and why you think that's the case!

Use the scrubber (the play bar at the bottom left) to check the value of your variables if you're not clear on what's happening. Click on the little toggle button to see information on each line!

Remember, the learning is in the struggle! Every time you get something wrong and solve it, you're becoming a coder, and eventually it will feel easy. Just keep going!

### Got it working but have an error still?

Lots of people get this exercise **almost** there but have an error such as "The first stem isn't correct?"

If that's you, watch this video to understand how to solve it:

<details><summary>Click to expand</summary>
<p><a href="https://www.loom.com/share/67b196e501e4479688c2afca9b9b1926?sid=30f1ebe8-f69b-4603-9f40-4088fdb4d3ed"/></p>

</details>
