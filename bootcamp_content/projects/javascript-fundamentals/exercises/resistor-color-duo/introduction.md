# Instructions

We're back with our second look at resistors, and this time we're looking at two color bands.

## Instructions

For this exercise, you need to know two things about them:

- Each resistor has a resistance value.
- Resistors are small - so small in fact that if you printed the resistance value on them, it would be hard to read.

To get around this problem, manufacturers print color-coded bands onto the resistors to denote their resistance values.
Each band has a position and a numeric value.

The first 2 bands of a resistor have a simple encoding scheme: each color maps to a single number.
For example, if they printed a brown band (value 1) followed by a green band (value 5), it would translate to the number 15.

In this exercise you are going to create a helpful functon so that you don't have to remember the values of the bands.

The function (`decodeValue`) will take color names as an array of strings, and should return a two digit number (even if the input is more than two colors!)

The band colors are encoded as follows:

- black: 0
- brown: 1
- red: 2
- orange: 3
- yellow: 4
- green: 5
- blue: 6
- violet: 7
- grey: 8
- white: 9

From the example above:

- `["brown", "green"]` return `15`
- `["brown", "green", "violet"]` should return 15 too, ignoring the third color.
