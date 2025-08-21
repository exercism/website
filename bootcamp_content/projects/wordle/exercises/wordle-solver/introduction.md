# Wordle

In the last Wordle exercise, you switched to using a `WordleGame` class.
This time, you're taking one step further, and actually working out how to solve the game!

To help, you now have:

- A new readonly property on `WordleGame` called `target_word`, which provides the target word.
- A new `common_words()` function that returns a list of the 100+ words that you can use in the game.

The key to this exercise is thinking through how to remember things, and how to use that memory to find the most efficient path to victory.

## Instructions

In this game, we don't provide you with any inputs.
Instead you have to discover the target word, just like you would in a game of Wordle.

There are three things you need to do:

1. Modify your `process_game` function to not take any inputs.
2. Draw the game board.
3. Continually guess the best possible word until you win or all 6 slots are full.

- For each word you guess, you should compare it to the `target_word` to build out the `"correct"`, `"present"` and `"absent"` states from the last exercise.
- You should then add it to the board.

**You should not use your ability to look up the target word as part of your guessing algorithm.** You should only use `target_word` for generating the correct states when you add it to the board.

The best possible word is defined as the **first word** in the list that, based on your knowledge so far:

- Has all the "correct" letters in the right places.
- Has all the "present" letters in a possibly correct slot.
- Has no "absent" letters.

For example:

1. You start by guessing at the word `"which"`.
2. You check it against the target word.
3. You find the `"w"` is correct, the `"h"` is present, and the other three letters are absent.
4. You add `"which"` to row `1` with the states of `["correct", "present", "absent", "absent", "absent"]`.
5. You then choose the next word in the list that starts with `"w"` and has an `"h"` in the third, fourth or fifth spots.
6. Go to (2)...

## Solving the exercise

This exercise is best solved by breaking it down into chunks.

The scenarios are broken into four groups (1, 2, 3-5, 6-9), which get progressively more complex. As you solve each group, we'll give you some more advice on what to do next at the bottom of these instructions. Keep an eye on it when you get scenarios passing.

## Library Functions

This exercise might benefit from your [`my#contains`](/bootcamp/custom_functions/contains) and your [`my#to_unique`](/bootcamp/custom_functions/to_unique) library functions.

## Functions

You have two function available:

- `common_words()`: Returns a list of common words.
- `push(list, element)`: This adds an element to a list, then returns the new list. It does not change the original list.

## Reminders

### Wordle rules

- There is a correct secret word.
- You have 6 guesses to get it right.
- For each guess:
  - If a letter is correct, it goes green
  - If a letter is present in the word but in the wrong place, it goes yellow.
  - If a letter is missing, it goes grey.

## The `WordleGame` class.

The `WordleGame` class is a blueprint for a wordle game.

An instance of WordleGame will have the following methods:

- `draw_board()`: Draws the board
- `add_word(row_idx, word, states)`: Adds a row at the given index (`1-6`) with a word and the same states you provided to `color_row` in the previous exercise.

It has one property that you can read:

- `target_word`: Provides the target word.

You should only make one instance of the class.
