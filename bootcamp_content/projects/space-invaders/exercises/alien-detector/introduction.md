# Space Invaders

In the last space-invaders exercise you moved your laser from side to side to shoot down all the aliens.
A big part of what made that possible was the `is_alien_above()` function.
In this exercise, we've removed it, but you still need to shoot down all the aliens!

We have put some sample code designed to help you get started.
Please feel free to reuse your code from the previous exercise if you choose.

This exercise is designed to be a challenge!
Take it slowly.

## Instructions

### Your tasks

You have two tasks.

1.  Shoot down all the aliens. Rather than being able to ask the exercise if there's an alien above you, you need to track which aliens you've shot down, and which are still there.
2.  When you've shot them all down, you should immediately use the `fire_fireworks()` function. This **must** happen in the same `repeat_until_game_over` iteration as shooting the final alien.

I highly recommend completing first task before starting the second.
The first few scenarios can be passed without the fireworks firing!

### Meet `get_starting_aliens_in_row(idx)`

You have a new function called `get_starting_aliens_in_row(idx)`.
It takes one input - the index of the row, starting from the bottom.
There are a maximum of three rows, so the input value can be `1`, `2`, or `3`.
We've written an example of this in your initial code to help you out.

The function returns a list of 11 booleans.
Each boolean specifies whether there is an alien in that position at the **start** of the exercise.
So `[true, false, false, ...]` would mean that, before you do anything, there is an alien in the first position, but not in the next two (etc).

The function returns the relevant positions for each scenario.

### Functions

You have four functions available:

- `shoot()`: Shoot upwards.
- `move_left()`: Move the laser one position to the left
- `move_right()`: Move the laser one position to the right
- `get_starting_aliens_in_row(idx)`: Explained in detail above.

### Notes

Some points of clarity:

- Every time you move left or right, you move one "position" forward or backwards. That position equates to the places the aliens can be.
- The aliens do not respawn in this exercise.

## Hints

You might find it easier to think about the fireworks last and just get the alien tracking and shooting sorted first.
