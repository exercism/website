# Write the can... functions

Last time you added a new function to help you navigate more delightfully: `turn_around()`.

Now it's time to implement some of the functions that already existed! We've taken away the `can_turn_left()`, `can_turn_right()` and `can_move()` functions, and your job is to add them back!
None of the functions have any inputs and all should return a boolean specifying whether it's possible to move in that direction.

To help you, we've added a new `look(direction)` function.
This function takes one input - a direction that can be `"left"`, `"right"`, or `"ahead"`.
It returns one of:

- `"start"` (Where you start)
- `"target"` (Where you're trying to get to)
- `"empty"` (The route forward!)
- `"fire"` (Careful!)
- `"poop"` (Ewww)
- `"wall"` (Ouch!)

You shouldn't need to change any of the existing code for this exercise.
Instead add the three functions to the top of the code

### Top Tip

A best practice in an exercise like this is to start by creating the functions that the code needs to run (i.e.`can_turn_left()`, `can_turn_right()` and `can_move()`).
Set their return values to be some sensible default (either `true` or `false` in this case).

You can then implement the logic of each function and make some progress each time, rather than just consistently getting an error that a function doesn't exist until you've written the whole program.
