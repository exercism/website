# Flag of Greece

The flag of Greece is a tricky looking one, but when you break it down, it's quite logical! We've given you a variety of properties you can choose to use.

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag has colors of `#0D5EAF` and `white`.
- `display`: Used to turn an element into a grid container.
- `grid-template-areas`: Sets the grid's areas.
- `grid-template-columns`: Sets the layout of columns. You probably want to use some mixture of `fr` and `auto`.
- `grid-template-rows`: Sets the layout of rows. You probably want to use `fr` values.
- `grid-area`: Specify the grid area that a item should reside in.
- `column-gap`: Sets the gap between columns. Use % values.
- `row-gap`: Sets the gap between rows. Use % values.
- `gap`: Sets both the row and column gap. Use % values.
- `aspect-ratio`: Sets the aspect ratio of an element. You probably want to use `1` for this exercise.
- `height`: Depending on your browser, you might need to specify `height: 100%` alongside `aspect-ratio`.

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
#flag div:nth-child(3) {
  ...;
}
```

Remember to nest the `div:nth-child` selector if you take this approach, else you might end up adding rules to other divs that you can't see.
