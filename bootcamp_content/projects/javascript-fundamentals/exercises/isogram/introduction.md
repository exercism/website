# Isogram

In Coding Fundamentals we looked at pangrams and anagrams.
Now we're looking at isograms!

An isogram (also known as a "non-pattern word") is a word or phrase without a repeating letter. (however spaces and hyphens are allowed to appear multiple times).

Examples of isograms:

- lumberjacks
- background
- downstream
- six-year-old

The word _isograms_, however, is not an isogram, because the s repeats!

## Instructions

Your job is to create a function `isIsogram` that takes a string as its input and returns a boolean for whether the input is an Isogram.

There are lots of ways to solve this! Remember to check the various [string methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String) (e.g. `replaceAll`, `toLowerCase` and `split` and `length`) and [array methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array) (e.g. `filter` and `indexOf`) on MDN!
