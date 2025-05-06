# Flag of Liberia

The Flag of Liberia is a stripey flag with a star in a blue square in the top left.

This flag will challenge you to use all the techniques you've practiced so far!

We've provided you with the star image as an svg.

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag has stripes of of `#bf0a30` and `white`. The background of the star is `#002868`.
- `display`: Used to turn an element into a flexbox container.
- `flex-basis`: Used to specify the initial size of an element on the main axis. Use percentages in this exercise (divisible by 10).
- `flex-direction`: Used to determine the direction that the flex container arranges its items.
- `flex-grow`: Used to specify whether an element should grow to fill the remaining space.
- `justify-content`: Used to justify content on the main axis.
- `align-items`: Used to justify content on the secondary axis.
- `aspect-ratio`: Used to set the aspect ratio of an element. (e.g. `1` makes something square, `1.5` makes something into a rectangle).
- `width`: You can set the width of the image using this property. It should be a percentage (divisble by 10).

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
section div:nth-child(3) {
  ...;
}
```
