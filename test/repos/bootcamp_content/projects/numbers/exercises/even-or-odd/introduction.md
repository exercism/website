# Even or odd

This exercise is very similar to "Positive, Negative or Zero", but this time you need to write the function from scratch. If you're stuck you can always look back at that exercise for a hint.

## Instructions

Your job is write a function called `even_or_odd`.

It should have one input that expects a _number_. It should return a _string_ specifying whether the number is `"Even"` (0, 2, 4, 6, 8, etc), or `"Odd"` (1, 3, 5, 7, etc).

To approach this problem, think about what it is that actually makes a number odd or even.

Remember, that Jiki understands plus (`+`), minus (`-`), multiply (`*`), divide (`/`) and remainder (`%`). Check the [Numbers Concept](https://exercism.org/bootcamp/concepts/numbers) for a recap on how they work.

## Bonus Task

Can you solve this exercise with only 6 lines of code?

## Hints

<details>
<summary>Hint 1: No idea where to start?</summary>

Even numbers are numbers that do not have a remiander when divided by 2.

You probably remember from school that a remainder is what’s left over when you divide a number but can’t divide it evenly. In other words, it’s the part of the number that doesn’t fit into equal groups.

For example, if you divide 7 by 3, you can fit two groups of 3 into 7 (since 3 + 3 = 6), but there’s 1 left over. That leftover 1 is the remainder. And that remainder makes it an odd number.

So to solve this exercise, you might like to use the **[remainder operator](https://exercism.org/bootcamp/concepts/numbers)**.

</details>
