# Wordle Rules

In the last Wordle exercise, you built out logic to color the rows.
This time, you're going to modify your code to use the new `WordleGame` class and, if you want to take on the bonus, add an extra rule.

## The `WordleGame` class

The `WordleGame` class is a blueprint for a wordle game.
The constructor of the class takes zero inputs (so you don't use any inputs when creating an instance).

An instance of WordleGame will have the following methods:

- `draw_board()`: Draws the board
- `add_word(row_idx, word, states)`: Adds a row at the given index (`1-6`) with a word and the same states you provided to `color_row` in the previous exercise.

You should only make one instance of the class.

## Instructions

Edit your code to create a `WordleGame` instance, draw the board and update add words.

Rather than using the `color_row` function to update the `states`, you should use the methods on your wordle game instance.
You also no longer need your `process_first_guess` function.

## Functions

You have one function available:

- `push(list, element)`: This adds an element to a list, then returns the new list. It does not change the original list.

## Reminder of Wordle rules

- There is a correct secret word.
- You have 6 guesses to get it right.
- For each guess:
  - If a letter is correct, it goes green
  - If a letter is present in the word but in the wrong place, it goes yellow.
  - If a letter is missing, it goes grey.
