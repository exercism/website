# Sleepy House

In Level 8 you sent the house off to sleep by updating properties.
You used classes for the elements like `Sky` and `Door`.
In this exercise, you're going to implement those classes yourself!

You still need a way of drawing things though. Previously, you've used methods like `rectangle` and `circle`, but this time we've exposing a little more depth to you and letting you use their underling `Rectangle`, `Circle`, and `Triangle` classes.

### The `HSLColor` class

The `HSLColor` class allows you to make an HSL color. Its constructor takes a `hue`, and `saturation` and a `luminosity`. It has readonly properties for `hue`, `saturation` and `luminosity` and no methods.

### The `Rectangle` class

The `Rectangle` class has a constructor that takes `left, top, width, height, hsl, z_index`. The `hsl` input should be an instance of the `HSLColor` class.

The Rectangle has two properties `hsl` and `brightness`. Changing these updates the image.

### The `Circle` class

The `Circle` class has a constructor that takes `cx, cy, radius, hex_fill_color, z_index`. The `hex_fill_color` input must be a value 6 letter hex code preceeded by a `#` (e.g. `#ff0000`).

The `Circle` class has three properties `cx`, `cy` and `brightness`. Changing these updates the image.

### The `Triangle` class

The `Triangle` class has a constructor that takes `x1,y1, x2,y2, x3,y3, hex_fill_color, z_index`. The `hex_fill_color` input must be a value 6 letter hex code preceeded by a `#` (e.g. `#ff0000`).

The `Triangle` class has one property `brightness`. Changing this updates the image.

## Instructions

We've put a working solution to animate the house in editor. You need to make the 7 classes. Here are constructors:

- `Sky`: (No inputs).
- `Sun`: `(cx, cy)`
- `Ground`: `(height)`
- `Frame`: `(left, top, width, height)`
- `Roof`: `(width, height)`
- `Window`: `(left, top)`
- `Door`: `(left, top)`

You will need to refer to the details at the bottom for certain values when drawing your shapes.

You can work out the properties and methods they need by reading the provided readonly code in the editor.

You can choose colors freely, with two exceptions:

1. When the lights turn on, they should be changed to an Hue of 56, a saturation of 100, and a luminosity of 50.
2. The sky's hue must start at 190 and finish at 310

### Functions

You only have one function available:

- `min(num1, num2)`: Returns the smaller of the two numbers.

### Reminder: House Instructions

- The sun starts with a cx of 80, a cy of 20, and a radius of 10.
- The top-left of the drawing canvas is `0,0`. The bottom-right is `100,100`.
- The frame of the house (the big rectangle) should be 60 wide and 40 height. It should have it's top-left corner at 20x50.
- The roof sits snuggly on top of the house's frame. It should overhang the left and right of the house by 4 on each side. It should have a height of 20, and it's point should be centered horizontally (50).
- The windows are both the same size, with have a width of 12 and a height of 13. They both sit 5 from the top of the house frame, and 10 inset from the sides.
- The door is 14 wide and 18 tall, and sits at the bottom of the house in the center.
- The little door knob has a radius of 1, is inset 1 from the right, and is vertically centered in the door.
