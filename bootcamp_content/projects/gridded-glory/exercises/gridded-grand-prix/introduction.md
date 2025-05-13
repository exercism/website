# Checkered Flag

Next we have the checkered flag, commonly seen in motorracing!

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag has stripes of of `black` and `white`.
- `display`: Used to turn an element into a grid container.
- `grid-template-columns`: Sets the layout of columns.
- `grid-template-rows`: Sets the layout of rows.

You might find it helpful to use the `odd` and `even` `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
#flag div:nth-child(odd) {
  ...;
}
```

Remember to nest the `div:nth-child` selector if you take this approach, else you might end up adding rules to other divs that you can't see.
