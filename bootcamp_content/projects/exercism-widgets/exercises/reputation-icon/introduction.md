# Reputation Icon

In this exercise, we're recreating the reputation icon that you can find on the top bar inside Exercism.

We're specifically looking at the state when there is a reputation notification signified by the red dot.

## Instructions

You can solve this using whichever properties you want.

**Colors:**

There are four colors used:

- Dark Blue: `#130b43`
- Pinky Purple: `rgb(136, 0, 254)`
- Red: `#EB5757`
- White: `white`

**Sizes:**

- Everything uses pixels other than one border radiuses and the outermost height of `100%`;
- Other than the font-size, everything is divisble by 5, except for the dot (see below)

**Image:**

The reputation icon lives at
`/bootcamp/images/reputation icon.svg`

**The dot**

The dot is somewhat arbitarily positioned by design. I recommend **not** using transform with the top and instead finding the right manual offsets.
