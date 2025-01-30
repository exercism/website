# Space Invaders

In the last episode you managed to move your laser from side to side and shoot down all the aliens.
A big part of what made that possible was the `is_alien_above()` function.
In this exercise, we've removed it, and you need to implement it yourself!

To help, you can now get the three rows of aliens using a the `get_alien_row(row)` function.
The function has one input - a number which is the row you're interested in (`1` is the bottom, `2` is the next up, etc).
It returns a list of strings representing the aliens on that row.
Each string can be `alive`, `dead`, or `""` - the empty string meaning there was no alien there.

Your job is create the `is_alien_above(col)` function.
It should have one input - a number representing the current column the laser is under, starting at 1 for the initial position.
It should return true if there is an alive alien in any of the rows above the character, and false otherwise.

We have given you some working code from the last exercise.
