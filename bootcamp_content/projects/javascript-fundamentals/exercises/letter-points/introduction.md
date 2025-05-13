# Scrabble Score

[Scrabble](https://en.wikipedia.org/wiki/Scrabble) is a word game where players place letter tiles on a board to form words.
Each letter has a value.
A word's score is the sum of its letters' values.

Your task is to compute a word's Scrabble score by summing the values of its letters.

The letters are valued as follows:

| Letter                       | Value |
| ---------------------------- | ----- |
| A, E, I, O, U, L, N, R, S, T | 1     |
| D, G                         | 2     |
| B, C, M, P                   | 3     |
| F, H, V, W, Y                | 4     |
| K                            | 5     |
| J, X                         | 8     |
| Q, Z                         | 10    |

For example, the word "cabbage" is worth 14 points:

- 3 points for C
- 1 point for A
- 3 points for B
- 3 points for B
- 1 point for A
- 2 points for G
- 1 point for E

## Instructions

In this exercise you need to create **TWO** functions.

The first is called `letter_values` which should return a dictionary.
Each key should be a **single** letter from the table above.
Each value should be its points as a number.
We've given you a list of lists, which you need to convert into that dictionary.
To solve this exercise properly, you need to use this as your starting point, rather than typing out the dictionary manually.

The second is `scrabble_score` which takes a word as its input, and expects you to return its score.
It should use the `letter_values` to calculate the score.

## Functions

You do not need any prewritten functions to solve this exercise.
However, you might come up with a solution that would benefit from you having the `concatenate(str1, str2, ...)` function, so we have give you access to that in case you want to use it.

## Hints

Stuck? Click to expand!

<details><summary>Helper Functions</summary>

There are lots of helper functions that could be useful here. For example, most languages provide:

- `contains`, which tells you whether one string contains another.
- `index_of`, which tells you where in a list/string an item is
- `to_upper_case`, which turns a string into its upper case equivalent.

Starting off by adding these functions will make your life a lot easier.

Maybe you've already written those functions in other exercises and you can reuse them here?

</details>
