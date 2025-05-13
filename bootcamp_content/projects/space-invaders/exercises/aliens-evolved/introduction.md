# Aliens Evolved!

Welcome to Space Invaders!

For those of you that took part in Coding Fundamentals, this exercise should feel very familiar. You can use your code from Alien Detector as a reference, although there are a few differences to be away of (see below!)

## Instructions

Your job in this exercise is create a function called `playGame()` to shoot down all the aliens!

You have four functions available to you:

- `shoot()`: Shoot upwards.
- `moveLeft()`: Move the laser one position to the left
- `moveRight()`: Move the laser one position to the right
- `getStartingAliens()`: Explained in detail below.

### The `getStartingAliens() function`

The function returns an array containing three rows (top to bottom).
Each row is an array containing a boolean stating whether there is an alien in that slot.

The function returns the same thing each time.
It is purely the starting information for you.
Your job is to keep track of the alien positions yourself.

For example, this code would mean there is an alien in the leftmost space of the highest row.

```
[
  [true, false, false, ...]
  ...
]
```

### The game loop

We've provided a starting game loop. This isn't a syntax you've seen yet, but you can read it as "loop 100 times".
It is expected that you will exit from the loop (via `break` or `return`) when you have shot everything down, but we've put a maximum of `100` so you don't end up crashing your browser.

### Notes

Some points of clarity:

- Every time you move left or right, you move one "position" forward or backwards. That position equates to the places the aliens can be.
- You cannot shoot twice in a row without moving.
- The aliens do not respawn.

## Reusing Alien Detector (Coding Fundamentals students)

If you reuse your Alien Detector code, here are a few notes:

- Be careful of the `in` vs `of` in the for each loops.
- Remember indexing starts at `0`, not `1` in JavaScript.
- You previously used a function three times to get three rows. Now you just get one nested array.
- You don't have `repeat_until_game_over`, so you need to use the loop provided.
