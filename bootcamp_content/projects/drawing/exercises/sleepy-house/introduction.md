# Sleepy House

We're back with the house you drew way back in Levels 1 and 2.

We're going to refactor the code to use objects, and we're going to animate it as night sets in.

We've given you your code from Structued House, but you might choose to keep or remove it.

## The Classes

You have a few Classes (blueprints) to use.
They abstract away some of the information about drawing.
For example, the color or the position of the sky is preset, it's not something you choose.

All of the Classes' constructors expect you to provide a "z index". This is how far off the screen, towards you, the objects sit.
Something with a lower z-index sits towards the back, and something with a higher z-index sits towards the front.
You can use a range of numbers, but keeping your values low (0-100) is sensible.

These are the constructors of the classes you have:

- `Roof`. The constructor expects`x_center, top, width, height, z_index`. It has a brightness property you can change, but not read.
- `Frame`: The constructor expects `left, top, width, height, z_index`. It has a brightness property you can change, but not read
- `Window`: The constructor expects `left, top, width, height, z_index`. It has a `lights` property that can be set to `true` or `false`. It has a brightness property you can change, but not read.
- `Door`: The constructor expects `left, top, width, height, z_index`. It has a brightness property you can change, but not read.
- `Sky`: The constructor expects `z_index`. It has a `hue` property that you can read and change, and a brightness property you can change, but not read.
- `Ground`: The constructor expects `height, z_index`. It has a brightness property you can change, but not read.
- `Sun`: The constructor expects `cx, cy, radius, z_index`. It has `cx` and `cy` properties that can be read and change.

## Instructions

Follow these steps:

1. Draw the scene as it was previously (the original instructions are at the bottom).
2. Add the sun, starting with a cx of 80, a cy of 20, and a radius of 10.
3. Animate the sun, moving by towards the bottom left by 1.2 x and 1 height each time. Once it dips below the horizon (cy of `90`) stop. It should have a `cx` of `-4` at that point.
4. Turn the lights on in both windows.
5. Simultaneously:

- Increase the sky's hue in increments of 2 until it reaches 310
- Change the ground, sky, roof, frame and door's brightness from 100 to 20 in increments of 1.

(Note: Both animations should start at the same time. However, the sky's hue will reach 310 before before the brightnesses reach 20).

The resulting scene should look like this:

<details><summary>Click to expand</summary>

<img src="https://assets.exercism.org/bootcamp/graphics/sleepy-house.gif" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>
</details>

### Functions

You only have one function available:

- `min(num1, num2)`: Returns the smaller of the two numbers.

### Reminder: House Instructions

- The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`.
- The frame of the house (the big rectangle) should be 60 wide and 40 height. It should have it's top-left corner at 20x50.
- The roof sits snuggly on top of the house's frame. It should overhang the left and right of the house by 4 on each side. It should have a height of 20, and it's point should be centered horizontally (50).
- The windows are both the same size, with have a width of 12 and a height of 13. They both sit 5 from the top of the house frame, and 10 inset from the sides.
- The door is 14 wide and 18 tall, and sits at the bottom of the house in the center.
- The little door knob has a radius of 1, is inset 1 from the right, and is vertically centered in the door.
