# Space Invaders

In the last space-invaders exercise moved your laser from side to side to shoot down all the aliens.
A big part of what made that possible was the `is_alien_above()` function.
In this exercise, we've removed it, but you still need to shoot down all the aliens!

We have put some sample code designed to help you get started.
Please feel free to reuse your code from the previous exercise if you choose.

This exercise is designed to be a challenge!
Take it slowly.

## Instructions

### Your task

Your task is to shoot down all the aliens.
Rather than being able to ask the exercise if there's an alien above you, you need to track which aliens you've shot down, and which are still there.
When you've shot them all down, you should immediately use the `fire_fireworks()` function.
This **must** happen in the same `repeat_until_game_over` iteration as shooting the final alien.

### `get_starting_aliens_in_row`

You have a new function called `get_starting_aliens_in_row(row)`.
It takes one input - the index of the row, starting from the bottom.
There are a maximum of three rows, so the input value can be `1`, `2`, or `3`.
We've written an example of this in your initial code to help you out.

The function returns a list of 11 booleans.
Each boolean specifies whether there is an alien in that position at the **start** of the exercise.
So `[true, false, false, ...]` would mean that, before you do anything, there is an alien in the first position, but not in the next two (etc).

### Notes

Some points of clarity:

- Every time you move left or right, you move one "position" forward or backwards. That position equates to the places the aliens can be.
- The aliens do not respawn in this exercise.

## Bonus Task

If you've got everything working - congratulations!
Now, can you beautify your code to make it cleaner?
Can you get rid of duplication?

Experiment with different approaches.
Where do functions help?
Where do they actually make it messier?
Can you use extra lists to clean things up more?
