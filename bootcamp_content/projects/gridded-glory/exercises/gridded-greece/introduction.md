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

If you are on some versions of Firefox and Safari, you might also need `height` an `z-index`. See the note below.

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
#flag div:nth-child(3) {
  ...;
}
```

Remember to nest the `div:nth-child` selector if you take this approach, else you might end up adding rules to other divs that you can't see.

## Firefox / Safari

Some versions of Firefox and Safari don't respond as intelligently to aspect-ratio as well as other browsers. They can't decide whether to calculate the column size or the aspect ratio first.

You have two choices to resolve this:

1. Set the width of the cross. The best way to do this is to set `grid-template-columns: calc(10/27 * 100%) 1fr` on your outer container. (You could with some thought come up with 10/27 yourself based on the aspect ratio, but it's not a good use of your time!)
2. The second option is to set a `height: 100%` next to the `aspect-ratio: 1` on the cross itself. This will force the cross to appear, but you'll likely get a weird rendering in Firefox as the cross will sit over the top of the stripes. To resolve this you can set a `background-color: white` and a `z-index: 2`, which together raise the cross above the stripes.

Both techniques are a little frustrating, but learning how to make things work with different browsers as their support for newer properties (like `aspect-ratio`) matures is a key part of front-end web development!
