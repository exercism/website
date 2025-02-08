# Weather Symbols (Part 1)

In the last exercise, you drew the sun peaking out behind a raining cloud.

For our next step, we're going to start to draw a wider range of weather symbols, made up of smaller components.
It's split into two parts.

In this first part, we're going to take a weather description (like `sunny` or `rainbow-territory`) and turn it into a list of the components that need drawing.
This is how they should map:

- `"sunny"`: `["sun"]`
- `"dull"`: `["cloud"]`
- `"miserable"`: `["cloud", "rain"]`
- `"hopeful"`: `["sun", "cloud"]`
- `"rainbow-territory"`: `["sun", "cloud", "rain"]`
- `"exciting"`: `["cloud", "snow"]`
- `"snowboarding-time"`: `["sun", "cloud", "snow"]`

In the next exercise, we'll turn these into drawings.

## Instructions

Create a function called `description_to_elements(description)`.
It takes the description as a string as an input.
It should return the list of components to draw.
