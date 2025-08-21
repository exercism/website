# Wordle

Welcome to Wordle, the classic Lockdown game!

The game works like this:

- There is a correct secret word.
- You have 6 guesses to get it right.
- For each guess:
  - If a letter is correct, it goes green
  - If a letter is present in the word but in the wrong place, it goes yellow.
  - If a letter is missing, it goes grey.

## Instructions

Your job is to create two functions. The first is called `process_first_guess` and it should handle one guess. The second is `process_game` which should process the whole game.

### Process Guess

Create a function called `process_first_guess`.
It should take two inputs:

1. The secret target word.
2. The guess the player has made.

You should work out the state of each letter then call the `color_row(1, states)` function with a state for each square in the first row. Either: `"correct"`, `"present"`, or `"absent"`.

For example, if the word was correct, you would call:

```jikiscript
color_row(1, ["correct", "correct", "correct", "correct", "correct"])
```

### Process Game

Create a function called `process_game`.
It should take two inputs:

1. The secret target word.
2. The list of the guesses the player has made. Each guess is a string.

You should work out the state of each row then call the `color_row(row, states)` function with the row (`1-6`), and a list of strings representing the state for each letter in the row.

For example, if the word was in the first row was correct, you would call:

```jikiscript
color_row(1, ["correct", "correct", "correct", "correct", "correct"])
```

## The `push` function

In this exercise, you'll need to use the `push` function for the first time. This is a function that you'll be using in nearly every exercise moving forward.

To "push" onto a list means to add an element to the end of it.

To use the push function, you provide two inputs:

- The list you want to add something to
- The element you want to add.

The function returns a **new** array with the contents of the list and the extra element added. It does not mutate the original list.

For example:

```jikiscript
set names to ["Jeremy", "Rubber"]
set new_names to push(names, "Duck")

// new_names is now ["Jeremy", "Rubber", "Duck"]
// names is still ["Jeremy", "Rubber"]
```

Often you do want to replace the old list with the new one. To do that, you can put the new list that the function returns into the original box. For example:

```jikiscript
set names to ["Jeremy", "Rubber"]
change names to push(names, "Duck")

// names is now ["Jeremy", "Rubber", "Duck"]
```

## Library Functions

This exercise might benefit from your [`my#contains`](/bootcamp/custom_functions/contains) library function!

## Functions

You have one function available:

- `push(list, element)`: This adds an element to a list, then returns the new list. It does not change the original list.
