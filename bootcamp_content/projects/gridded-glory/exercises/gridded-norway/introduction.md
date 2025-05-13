# Flag of Norway

Next we have the flag of Norway. This is a similar flag to one you had with Flexbox, but a little more complex.

The blue lines are the same width and height horizontally and vertically, so the blue rectangle in the middle is a square. Similarly the white lines are the same width and height.

You can use the fact that the flag has an aspect ratio of 1.5 to make this easier for yourself. Something with a width of 9% is the same size as something with a height of 6%. I recommend specifying % widths for the white and blue sections, and for the width of the red squares. The remaining space can flow via fractional units.

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag has stripes of `white`, `#BA0C2F` and `#00205B`.
- `display`: Used to turn an element into a grid container.
- `grid-template-rows`: Sets the layout of rows.
- `grid-template-columns`: Sets the layout of columns.
- `grid-column`: Specify the start and end column lines of a grid item.
- `grid-row`: Specify the start and end row lines of a grid item.

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
#flag div:nth-child(3) {
  ...;
}
```

Remember to nest the `div:nth-child` selector if you take this approach, else you might end up adding rules to other divs that you can't see.
