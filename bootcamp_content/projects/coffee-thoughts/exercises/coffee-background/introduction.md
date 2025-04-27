# Background

To add a bit more style - we're going to add a background image to our Coffee Thoughts.

To set backgrounds, we have a number of properties we can use:

- `background-image: url(...)`: Sets the url of a background image.
- `background-size`: Can be lots of values. In this exercise, we want the image to cover our space, so we use the `cover` value.
- `background-color`: Specify a color to render **below** the background image. As the image is partially transparent, this color shows through.

There are many other properties too, but we don't need them here.

## Instructions

Firstly, we've removed some hidden styling. You'll need to reimplement that with two steps:

1. In your HTML, wrap all of the content in a new element.
2. In the CSS, add some padding to that element.

**If you use `padding` or `margin`, use `%` values.**

We've created a very transparent image of some coffee beans. It lives at `/bootcamp/images/coffee-beans.png`. You should set the background of your new element to be this image along with a underlying color of `#e1d3c6`.

### Contrast

It's very important when adding background colors or images to consider the level of contrast between the text and the background. While our coffee beans might look nicer than a plain color, they make the text a little harder to read.

There are lots of tools online to help you understand whether your contrast is ok. They general use the WCAG guidelines - a set of web accessibility guidelines - and measure your performance.

You can learn more about this at [MDN](https://developer.mozilla.org/en-US/docs/Web/Accessibility/Guides/Understanding_WCAG/Perceivable/Color_contrast).

For now, let's check our contrast using an online tool (e.g. [Webaim's](https://webaim.org/resources/contrastchecker/)). Always input the values for the darkest point of your background (`#D2C1B4`) and the lightest text you use (`#442A12`). See if the tool thinks you're ok!
