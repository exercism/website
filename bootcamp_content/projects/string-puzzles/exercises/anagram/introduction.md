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

Create a function that called `find_anagrams(word, possibilities)` that takes a target word (a string) and a list of possible acronyms, and returns which of the posssibiles are actually anagrams of the target.

Some notes:

- An anagram is a rearrangement of letters to form a new word: for example `"owns"` is an anagram of `"snow"`.
- A word is _not_ its own anagram: for example, `"stop"` is not an anagram of `"stop"`.
- The target word and possible words are made up of one or more ASCII alphabetic characters (`A`-`Z` and `a`-`z`).
- When determining if something is an anagram, lowercase and uppercase characters are equivalent. For example, `"PoTS"` is an anagram of `"sTOp"`, but `"StoP"` is not an anagram of `"sTOp"`.
- You should return the anagrams with the same casing as they are specified in the possibilities list. For example, if `"sTOp"` is in the possibilities list, you should return it cased as `"sTOp"`, not `"stop"`, even if the target word is `"pots"`.

For example:

```jikiscript
find_anagrams("stone", ["stone", "Seton", "banana", "tons", "notes", "tones"])

// Should return...
// ["Seton", "notes", "tones"]
```

## Library Functions

This exercise will benefit from you using your library functions. The following in particular might be useful:

- [`my#to_lowercase`](/bootcamp/custom_functions/to_lowercase/edit) or [`my#to_uppercase`](/bootcamp/custom_functions/to_uppercase/edit)
- [`my#index_of`](/bootcamp/custom_functions/index_of/edit)

## Functions

You have three built-in functions avaible:

- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `push(list, elem)`. Returns a new list with the element added to the original list.
- `sort_string(string_or_list)`: Takes a string or a list and returns a string with its contents sort alphabetically.
