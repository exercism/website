# Pangram

You work for a company that sells fonts through their website.
They'd like to show a different sentence each time someone views a font on their website.
To give a comprehensive sense of the font, the random sentences should use **all** the letters in the English alphabet.

They're running a competition to get suggestions for sentences that they can use.
You're in charge of checking the submissions to see if they are valid.

```exercism/note
Pangram comes from Greek, παν γράμμα, pan gramma, which means "every letter".

The best known English pangram is:

> The quick brown fox jumps over the lazy dog.
```

## Your Task

Your task is to figure out if a sentence is a pangram.

A pangram is a sentence using every letter of the alphabet at least once.
It is case insensitive, so it doesn't matter if a letter is lower-case (e.g. `k`) or upper-case (e.g. `K`).

For this exercise, a sentence is a pangram if it contains each of the 26 letters in the English alphabet.

## Instructions

Create a function called `is_pangram` that takes a sentence as a string, and returns a boolean representing whether it is, or is not, a pangram.

You can solve this exercise in multiple ways.
Try and experiment with different approaches using both lists and dictionaries to see what you prefer.

### Functions

You have two functions available:

- `concatenate(str1, str2)`: This takes two strings and returns them joined together.
- `keys(dictionary)`.: This takes a dictionary as its input and returns a list of all its keys.

## Hints

Stuck? Click to expand!

<details><summary>Helper Functions</summary>

There are lots of helper functions that could be useful here. For example, most languages provide:

- `contains`, which tells you whether one string contains another.
- `index_of`, which tells you where in a list/string an item is
- `to_lower`, which turns a string into its lowercase equivalent.

Starting off by adding these functions might make your life a lot easier.

Maybe you've already written those functions in other exercises and you can reuse them here?

</details>
