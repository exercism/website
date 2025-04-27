# Love-Poured Candles

In this exercise, your job is to make a recipe card.

We've given you a blank slate, but it's a straight-forward thing to structure.

There are two properties you've not used before:

- `text-transform`: If you want to make text uppercase for visual reasons (ie it looks nicer that way), you should still write it using normal casing, but then apply the `text-transform: uppercase` property. For example, you could write `"Jeremy Walker"`, but then use this property to make it visually appear as `"JEREMY WALKER"`.
- `list-style-type`. By default, unordered lists use bullet points as the "marker" of the list. However, you can change this to be a different decorative item, using the `list-style-type` property. It accepts some special values like `circle` or `square` but it also accepts strings containing character(s) (e.g. `list-style-type: "a"` would make the markers all be `"a"`, or `"- "` would add a dash and a space). Emojis are characters too...

## Instructions

Firstly, write out your HTML with a sensible structure. Then style the card itself, then style the text and space it appropriately!

We've setup the exercise so that the first element you create will fill all the horizontal space but not the vertical space.

You need one image for the lemons (which should be used as a background images). It is available at `/bootcamp/images/lemons.jpg`.

### CSS Properties Used

You will probably want to make use of all of the properties. **In order to get things identical, you should be careful to use the units specified below** (e.g. `%` or `px`):

- `margin`: Use `%` in this exercise.
- `padding`: Use `%` in this exercise.
- `background-image: url(...)`: Sets a background image.
- `background-size`: Sets the size of the background image. Choose from `cover`, `contain` or `%` in this exercise.
- `background-position`: Sets the position of the background image. This property has lots of options, but in this exercise, you need to choose two of `top`, `bottom`, `left`, and `right` seperated by a space (e.g. `background-position: top left`).
- `background-repeat`: Determines whether the background should repeat. To stop it from repeating, you can use the `no-repeat` value.
- `font-size`: Use `px` values for this exercise.
- `font-weight`: You need `bold` for this exercise.
- `font-style`: You can use the `italic` value here.
- `color`: You need `#4b3f2f` and `#777` for this exercise.
- `border`: The border on the edge of the card is colored `e3caa5`.
- `border-radius`: Use `px` values for this exercise.
- `list-style-type` (or `list-style` shortcut): See above.
- `text-transform` (or `list-style` shortcut): See above.

Please note that all values (`px` and `%`) should be round numbers!

Remember to use the diff and curtain if you get stuck, and to **start styling from the top-left** to keep things sane!
