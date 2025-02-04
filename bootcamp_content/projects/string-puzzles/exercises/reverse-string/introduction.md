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

- `join(str1, str2)`: This takes two strings and outputs them joined together.

### Emojis

Those last two scenarios are weird ones, aren't they... Any ideas what's going on?

It turns out that lots of emojis are acutally made up of other emojis joined together with hidden (zero width) spaces.

In the first example, the family emoji (👩‍👩‍👧‍👦) is made up of two women and two children. When it's reversed you can see the individual characters (👦‍👧‍👩‍👩).

In the second example we have a rainbow and a flag (🌈‍️🏳), but when we reverse the order to get the flag then the rainbow, it becomes a rainbow flag! (🏳️‍🌈️).
