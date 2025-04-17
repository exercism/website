# Omniscience

So far in the maze exercises, you've gone from using a high-level `can_turn_right()` function, to using a slightly lower-level `look(direction)` function.
In this exercise we take this one step further and leave navigation entirely in your hands!

This is one of the biggest and most complex exercises you've done so far.
It's **really** important to take it step by step.

### How it works

When you start the exercise you can use the new `get_initial_maze()` function to get all of the squares arranged in a list of lists.
Each list is a row (so `squares[1]` is the first row, and `squares[1][1]` is the top-left square).

Each square is an Instance of the Square, exactly the same as in the "Squares Not Strings" exercise.

There is one change, and that's the addition of a new method `remove_emoji()`. Previously, `remove_emoji()` was a function you called, passing in a square as an input.
Under the hood, that used the square's method.
Now you should use the method directly.

## Instructions

Your job is to upgrade your code to deal without having the built-in `look` function.

You should navigate around, keeping track of where you are, and working out where you can go next.
Collect the emojis and announce them at the end.

We've given you your "Squares not Strings" code as your starting point, and give you a variety of step-by-step scenarios to work through.
I highly recommend working through them one-by-one!

Some notes:

- Remember to stick to the original algorithm you were given.
- The easiest starting point is probably to implement your own `look` function.
- You always start on the starting square
- You always start looking into the maze (i.e. into a square that's not a wall or off the board). If there are multiple options, prioritise by downward, leftward, rightward, upward.
- Take this one step at a time. Start by positioning your character correctly, then get their initial direction right, then solve each scenario one-by-one!

## Recap

### The Square class

As a reminder, instances of the square class have a few properties you can use:

- `is_start`: A boolean representing whether this is the start square.
- `is_finish`: A boolean representing whether this is the finishing square.
- `is_wall`: A boolean representing whether this is the all square.
- `contents`: A string containing an emoji, or an empty string.

It also now has the method:

- `remove_emoji()`: Removes the emoji from the square.

### Emojis

Special emojis. Avoid these:

- `"🔥"` (Careful!)
- `"💩"` (Ewww)

Pick up the rest!

### Library Functions

This exercise will probably need your [`my#has_key`](/bootcamp/custom_functions/has_key/edit) library function!

### Functions

You have following game functions:

- `move()`
- `turn_left()`
- `turn_right()`
- `announce_emojis(dict)`
- `get_initial_maze()`
