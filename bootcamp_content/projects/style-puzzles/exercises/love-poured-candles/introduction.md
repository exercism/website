# Love-Poured Candles

In this exercise, your job is to make a business card for a Candle Maker.

You have a blank slate, and there's lots of ways you can do things, but we've put some guidance below.

## Instructions

Firstly, create your HTML structure. Work top-to-bottom and lay out the code in the most logical way you can. Then add the CSS next. Finally work out how to add the image where you want it.

We've setup the exercise so that the first element you create will fill all the horizontal space but not the vertical space.

You need two images (both of which should be set as background images):

- The paper texture image is available at `/bootcamp/images/paper-texture.jpg`. This image should `cover` the card, and be positioned at the `top left`.
- The candle image is available at `/bootcamp/images/candle.png`.

The three emojis used are `🌐`, `📧` and `📞`.
Although this might look like a good target for a list with custom markers, it's probably best to use a collection of divs instead here.
The emojis have meaning and we want to preserve those for SEO and screenreaders, not simply make our bullet points pretty like we did with the Lemonade exercise.

When we're a little more advanced, we would probably want to use a list, with markers hidden, but still with the emojis inline, with descriptions added to them. We'll come to that later 🙂

### CSS Properties Used

Use the following properties. **In order to get things identical, you should be careful to use the units specified below** (e.g. `%` or `px`):

- `margin`: Use `%` in this exercise.
- `padding`: Use `%` in this exercise.
- `background-image: url(...)`: Sets a background image.
- `background-size`: Sets the size of the background image. Choose from `cover` or `%` in this exercise.
- `background-position`: Sets the position of the background image. This property has lots of options, but in this exercise, you need to choose two of `top`, `left`, `bottom` and `right` separated by a space (e.g. `background-position: top left`).
- `background-repeat`: Determines whether the background should repeat. To stop it from repeating, you can use the `no-repeat` value.
- `font-size`: Use `px` values for this exercise.
- `font-weight`: You need `bold` for this exercise.
- `font-style`: You can use the `italic` value here.
- `color`: You need `#5b3a29` (heading) and `#8c6e54` (everything else).
- `border`: The border on the edge of the card is `double` with a color of `rgba(0, 0, 0, 0.2)`
- `border-radius`: Use `px` values for this exercise.

Please note that all values (`px` and `%`) should be whole numbers (e.g. 3%, 20px)!

Remember to use the diff and curtain if you get stuck, and to **start styling from the top-left** to keep things sane!

<hr class="mt-40 mb-32 border-borderColor5"/>

## Stuck?

A lot of people get to 97% on this exercise, and can't get the last few percent correct.
That's normally because they've missed an instruction, or taken a more "hacky" approach to something than we're hoping to see.

Here are common mistakes people make:

- Not checking the diff/curtain carefuly enough.
- Not using `cover` and `top left` for the paper background?
- Not using `%` for all margins and padding?
- Having slightly different corner radius (check the diff carefully).
- Not having the same padding all the way around. Instead people often have a different bottom padding. This should feel a bit yucky - can you find a different way?
- Using non-whole percentages (e.g 1.64%).
