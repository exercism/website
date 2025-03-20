# Alphanumeric

In this Library Function Exercise, your task is to create three functions all around checking whether a string contains letters and/or numbers.

As normal in these exercises, your job is to:

1. Write the library functions
2. Import them (using the dependencies button)
3. Finish the exercise.

Again, please remember that you might need to refresh this page in between writing your library function and importing it!

## The Library Functions

The library functions all check strings to see what type of characters they contain. These functions are very useful for data parsing.

- The first library function to add is [`my#is_numeric`](/bootcamp/custom_functions/is_numeric/edit).
  This determines whether a string only consists of numeric characters (`"0"`, `"1"`, `"456"`, etc).

- The second function is [`my#is_alpha`](/bootcamp/custom_functions/is_alpha/edit).
  This determines whether a string only consists of ascii letters (`"A"`, `"a"`, `"Hello"`, etc).

- The final function is [`my#is_alphanumeric`](/bootcamp/custom_functions/is_alphanumeric/edit).
  This determines whether a string only consists of ascii letters or numbers (e.g. `"Meaning"`, `"42"`, `"Meaning 42"`, etc).

For any other symbols (e.g `"! ?"`) or non-ascii characters (`じき`, `直々`), all three functions should return `false` .

## Instructions

For this exercise, you need to finish off a function that takes a string as an input and determines it's alpha numeric state.

The function should return one of the following depending on the result of your library functions:

- Strings with both letters and numbers should be `"Alphanumeric"`.
- Strings with only letters should be `"Alpha"`.
- Strings with only numbers should be `"Numeric"`.
- Everything else should be `"Unknown"`.
