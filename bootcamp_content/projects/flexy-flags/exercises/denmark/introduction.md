# Flag of Denmark

The Flag of Denmark is a red background with a white cross. How can you recreate this using flexbox?

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag of Denmark is a mixture of `white` and `#c8102e`.
- `display`: Used to turn an element into a flexbox container.
- `flex-basis`: Used to specify the initial size of an element on the main axis. Use percentages in this exercise (divisible by 10).
- `flex-wrap`: Specifies whether the elements of the flex-box should wrap onto the next line if they're too large to fill the space.
- `flex-grow`: Specifies whether an element should grow, and by how much compared to otehr elements.
- `gap`: Specifies the gap between elements. Use pixels for this exercise.

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
section div:nth-child(3) {
  ...;
}
```
