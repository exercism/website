# Reverse String

Reversing strings (reading them from right to left, rather than from left to right) is a surprisingly common task in programming.

For example, in bioinformatics, reversing the sequence of DNA or RNA strings is often important for various analyses, such as finding complementary strands or identifying palindromic sequences that have biological significance.

## Instructions

Your task is create a new function called `reverse`, which takes a string as its input, and returns the reversed version.

Some examples:

- Turn `"stressed"` into `"desserts"`.
- Turn `"strops"` into `"sports"`.
- Turn `"racecar"` into `"racecar"`.

### Functions

For this exercise, you have one function available:

- `concatenate(str1, str2, ...)`: This takes two or more strings and returns them joined together.

### Emojis

Those last two scenarios are weird ones, aren't they... Any ideas what's going on?

It turns out that lots of emojis are actually made up of other emojis joined together with hidden (zero width) spaces.

In the first example, the family emoji (👩‍👩‍👧‍👦) is made up of two women and two children. When it's reversed you can see the individual characters (👦‍👧‍👩‍👩).

In the second example we have a rainbow and a flag (🌈‍️🏳), but when we reverse the order to get the flag then the rainbow, it becomes a rainbow flag! (🏳️‍🌈️).

## Hints

Click to expand...

<details><summary>Stuck on the Emoji?</summary>

If you use the optimal method to solve this, the emojis should **just** work.
If you use a non-optimal method, you might run into trouble.
So try to simplify your code to solve this.

One method is to get out a pen and paper and reverse the word "robot" manually.
What steps do you take?
Can you do the same using code?

</details>

</details>
