# Love-Poured Candles

In this exercise, your job is to make a recipe card.

We've given you a blank slate, but it's a straight-forward thing to structure.

There are two properties you've not used before:

- `text-transform`: If you want to make text uppercase for visual reasons (ie it looks nicer that way), you should still write it using normal casing, but then apply the `text-transform: uppercase` property. For example, you could write `"Jeremy Walker"`, but then use this property to make it visually appear as `"JEREMY WALKER"`.
- `list-style-type`. By default, unordered lists use bullet points as the "marker" of the list. However, you can change this to be a different decorative item, using the `list-style-type` property. It accepts some special values like `circle` or `square` but it also accepts strings containing character(s) (e.g. `list-style-type: "a"` would make the markers all be `"a"`, or `"- "` would add a dash and a space). Emojis are characters too.

## Instructions

Firstly, write out your HTML with a sensible structure. Then style the card itself, then style the text and space it appropriately!

We've setup the exercise so that the first element you create will fill all the horizontal space but not the vertical space.

You need one image for the lemons (which should be used as a background images). It is available at `/bootcamp/images/lemons.jpg`.

### CSS Properties Used

You will probably want to make use of all of the properties.

Please note that all values

- `margin`: Should be a `px` value that is a multiple of 5 (e.g. `5px`, `10px`).
- `padding` Should be a `px` value that is a multiple of 5 (e.g. `5px`, `10px`).
- `background-image: url(...)`: Sets a background image.
- `background-size`: Sets the size of the background image. Use `cover` in this exercise.
- `background-position`: Sets the position of the background image. This should be `top right` in this exercise.
- `font-size`: Use `px` values.
- `font-weight`: You need `bold` for this exercise.
- `font-style`: You can use the `italic` value here.
- `color`: You need `#4b3f2f` and `#777` for this exercise.
- `border`: The border on the edge of the card is colored `e3caa5`.
- `border-radius`: Use a `px` value.
- `list-style-type` (or `list-style` shortcut): See above.
- `text-transform` (or `list-style` shortcut): See above.

Remember to use the diff and curtain if you get stuck, and to **start styling from the top-left** to keep things sane!

<hr class="mt-40 mb-32 border-borderColor5"/>

## Stuck?

A lot of people get to 97% on this exercise, and can't get the last few percent correct.
That's normally because they've missed an instruction, or taken a more "hacky" approach to something than we're hoping to see.

Here are common mistakes people make.
I recommend double-checking each of them!

- Not checking the diff/curtain carefuly enough.
- Not using `cover`, `top right` for the background.
- Unncessarily using `background-repeat: no-repeat`. This makes no visual difference, but does change the subpixel rendering.
- Not using `px` for all margins and padding.
- Having slightly different corner radius (check the diff carefully).
- Not all pieces of text have the correct color.
- Not having the text break correctly over two lines. You shouldn't use `<br>` to do this - use a padding/margin instead, so that your solution still works at different zoom levels.
- Not specifying a border width when using the shorthand syntax.
- The "marker" in the list (the thing you change with `list-style-type`) needs to use an emoji and have a space inside of it. Later on we'll learn how to add margins to markers, but for now, just include a space inside of it.
