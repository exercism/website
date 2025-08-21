# Flag of Romania

Welcome to a new set of Flag puzzles.
This time your job is to use CSS Grid to draw them. Once again, check the properties you're allowed to use, and spend time thinking through your designed to get started!

We're starting with the Flag of Romainia - a simple stripey flag.

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

You should **only** use the following properties:

- `background`: The flag has stripes of of `#002B7F`, `#FCD116` and `#CE1126`.
- `display`: Used to turn an element into a grid container.
- `grid-template-columns`: Sets the layout of columns.

You might find it helpful to use `nth-child` selectors in this exercise. We looked at these briefly in the teaching video. To target the 3rd div in a section, you could use:

```css
#flag div:nth-child(3) {
  ...;
}
```

Remember to nest the `div:nth-child` selector if you take this approach, else you might end up adding rules to other divs that you can't see.
