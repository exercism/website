# Task 4

There's one Wordle rule that we've skipped over so far...

If a letter appears twice in a guess, but only once in the target word, then either:

- The correct one should go green; or
- The first should go yellow.

The same rule scales for if there are three in a guess and two in a word.

Take a look at the second bonus scenario, you'll see why this is wrong. It very confusing that the fourth square in `"SWISS"` is yellow but then goes grey for `"SWIGS"`. So you need to change things so that that yellow square is grey in `"SWISS"`.

You need to partially solve the issue for the first bonus scenario (so start there!) then fully solve the problem for the second one.

This task is a challenge! **Remember it's a bonus - you don't have to complete it!**

Good luck!
