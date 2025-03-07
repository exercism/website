# Anagram

At a garage sale, you find a lovely vintage typewriter at a bargain price!
Excitedly, you rush home, insert a sheet of paper, and start typing away.
However, your excitement wanes when you examine the output: all words are garbled!
For example, it prints "stop" instead of "post" and "least" instead of "stale."
Carefully, you try again, but now it prints "spot" and "slate."
After some experimentation, you find there is a random delay before each letter is printed, which messes up the order.
You now understand why they sold it for so little money!

You realize this quirk allows you to generate anagrams, which are words formed by rearranging the letters of another word.
Pleased with your finding, you spend the rest of the day generating hundreds of anagrams.

## Instructions

Given a target word and one or more candidate words, your task is to find the candidates that are anagrams of the target.

An anagram is a rearrangement of letters to form a new word: for example `"owns"` is an anagram of `"snow"`.
A word is _not_ its own anagram: for example, `"stop"` is not an anagram of `"stop"`.

The target word and candidate words are made up of one or more ASCII alphabetic characters (`A`-`Z` and `a`-`z`).
Lowercase and uppercase characters are equivalent: for example, `"PoTS"` is an anagram of `"sTOp"`, but `"StoP"` is not an anagram of `"sTOp"`.
The words you need to find should be taken from the candidate words, using the same letter case.

Create a function called `find_anagrams` that takes two inputs:

1. A target word, as a string
2. Potential anagrams, as a list of strings.

It should return the anagrams as a list, in the same order the words were given.

For example:

```
find_anagrams("stone", ["stone", "tones", "banana", "tons", "notes", "Seton"])

// Should return...
// ["tones", "notes", "Seton"]
```
