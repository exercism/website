# Flag of The Gambia

Next we have the flag of The Gambia. A similar flag, but this time with vertical stripes. The white stripes are 1/18th of the size of the flag.

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag has stripes of of `#CE1126`, `#0C1C8C` and `#3A7728`.
- `display`: Used to turn an element into a grid container.
- `grid-template-rows`: Sets the layout of rows.

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
#flag div:nth-child(3) {
  ...;
}
```

Remember to nest the `div:nth-child` selector if you take this approach, else you might end up adding rules to other divs that you can't see.
