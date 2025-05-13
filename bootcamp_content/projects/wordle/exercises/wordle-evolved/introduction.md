# Wordle

Welcome to Wordle. This exercise is an evolution of the JikiScript Wordle Solver exercise from Coding Fundamentals. If you solved that, this is a transposition and refinement exercise. If you've not solved it, then you have a fun bit of problem-solving ahead!

## Wordle

Wordle is a game that became popular during COVID lockdowns. These are the rules.

- There is a correct secret word.
- You have 6 guesses to get it right.
- For each letter in a guess:
  - If correct, it goes green
  - If present in the secret word but in the wrong place, it goes yellow.
  - If absent from the secret word, it goes grey.
- When all squares go green for a word, you win!

## Instructions

Your have two jobs:

1. Correctly color-code words based on your knowledge of the guess and the secret word.
2. Make a working Wordle solver.

You have three functions to call:

- `getCommonWords()`: Returns a list of the 100+ words that you can use in the game.
- `getTargetWord()`: Returns the word you're trying to find, used for colouring worlds.
- `addWord(rowIdx, word, states)`: Adds a row at the given index (`0-5`) with a word and the correct color for each letter.

### Workflow

Your workflow is as follows:

1. Choose the first word (your "guess") from the array returned by `getCommonWords()`.
2. Compare each letter to the target word (returned by `getTargetWord()`), creating an array of 5 states: `"correct"`, `"present"`, or `"absent"`.
3. Call `addWord` with the row (starting with 0) the guess from (1) and the states from (2).
4. Store the information about this word (e.g. which letters we now know are in the right places, which are present but in the wrong places, etc).
5. Choose the next word from the array returned by `getCommonWords()` that is valid based on all the information you've learned so far about the target word (all the values from (4)).
6. Go to 2.

### Worked Example

1. You start by guessing at the word `"which"`.
2. You check it against the target word (`"worth"`). You find the `"w"` is correct, the `"h"` is present, and the other three letters are absent.
3. You call `addWord(0, "which", ["correct", "present", "absent", "absent", "absent"])`.
4. You add this information to your knowledge.
5. You then choose the next word in the `getCommonWords()` array that starts with `"w"` and has an `"h"` in the third, fourth or fifth spots.
6. Go to (2)...

### Notes:

- **You should not use your ability to look up the target word as part of your guessing algorithm.** You should only use `getTargetWord()` for generating the correct states when you add it to the board. You're both being the game engine, and playing the game here.

- The best possible word is defined as the **first word** in the list that, based on your knowledge so far:
  - Has all the "correct" letters in the right places.
  - Has all the "present" letters in a possibly correct slot.
  - Has no "absent" letters.

### Wordle rules

## Notes for Coding Fundamentals students

You can copy/paste your code from Wordle Solver and update it to be JavaScript. Then you can refine it afterwards.

There's a few things to be aware of:

1. There's no `WordleGame` class here and no drawing of the board. You have three functions instead.
2. JavaScript indexes from `0` not `1`!
3. You can replace a lot of your manual functions (e.g. `my#contains`) with built in JavaScript functions.
4. Rather than `repeat XXX times`, you can use the `for (let idx = 0; idx < XXX; idx++)` syntax.
