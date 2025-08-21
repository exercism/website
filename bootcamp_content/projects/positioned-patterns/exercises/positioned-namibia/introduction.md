# Flag of Namibia

This is a tough one!

The flag of Namibia has two challenging properties:

1. It has diagonal stripes
2. It has a tricky emblem that you need to create.

Consider this your final boss!

## Instructions

Behind the scenes we've added some CSS so that your outermost element will fill the space fully.

- You have a triangle image you can use, which lives at `/bootcamp/images/namibia-triangle.svg`.

### Stripes

For the stripes:

- The target implementation uses `%` divisible by 10 for all the positioning (e.g. any widths, heights, tops, lefts, etc) with two exceptions:
  - The width of the stripes, which is a mix of `%` (in 5% increments) and either `fr` or `flex-grow`
  - The rotation, which is a `%` divisible by 5.
- The blue is `#002f6c`, the red is `#c8102e`, the green is `#009a44` and the gold is `#ffcd00`

### The Emblem

For the emblem:

- The target implemenation uses `px` values for nearly everything. The only exception is `transform` and `border-radius` which use `%`.
- There is a straight-forward approach to positioning the triangles that is pain-free. Try and find the right method, not the right arbitary set of magic co-ordinates!

I highly recommend **not** embedding this in the blue section, else you're going to have to do a lot of maths with the rotations. Instead place it arbitarily on top of the stripes.

## Think first!

This exercise is not simple, but it **is** achievable. The key to all of the parts are choosing the right concepts and mechanisms. Get one part right first before worrying about the next part etc.

Good luck!
