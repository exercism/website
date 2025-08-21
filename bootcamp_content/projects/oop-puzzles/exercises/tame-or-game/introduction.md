# Tame or Game

It's raining. You're stuck inside. And in an effort to spice up the day, you decide to make a new twist on "Even or Odd" called "Tame or Game".

In reality, there's nothing too different about it, but you feel a bit better having given it a cool name!

## Instructions

Your job is write a class called `TameOrGame`.

It has one input in its constructor - the number that determines tameness or gameness.

It should methods for `is_tame()`, `is_game()` and `tame_or_game()`:

- `is_tame()` should return a boolean stating whether the number is even.
- `is_game()` should return a boolean stating whether the number is odd.
- `tame_or_game(prefix)` should return a string starting with the prefix and ending in either `is tame.` or `is game.`.

For example:

```jikiscript
game = new TameOrGame(5)
game.is_tame() // returns false
game.is_game() // returns true
game.tame_or_game("Jeremy") // returns "Jeremy is game."
```

## Functions

You have one function available:

`concatenate(str1, str2, ...)`: This takes two or more strings and returns them joined together.
