# Description

_This is the same exercise as ISBN Verifier in Coding Fundamentals and on Exercism. Can you solve it idiomatically in JavaScript?_

ISBNs are 10 digit numbers given to uniquely identify books.
Each one is unique and follows a specific format.
They also have a verification process to check they're real ISBNs.

ISBNs normally contain dashes and look like: `3-598-21508-8`

(There are also 13 digit ISBNs, but you can safely ignore those for this exercise!)

### Verifying an ISBN

To verify an ISBN, we:

- Start at the left and add together the digit multiplied by 10 down to 1.
- Get the remainder of that total divided by 11.
- Check whether that remainder is zero.

For example, for the ISBN `3-598-21508-8`, we would check whether:

```jikiscript
((3 * 10) + (5 * 9) + (9 * 8) + (8 * 7) + (2 * 6) + (1 * 5) + (5 * 4) + (0 * 3) + (8 * 2) + (8 * 1)) % 11 == 0
```

Since the result is 0, this proves that our ISBN is valid.

A couple more important notes:

- Sometimes an ISBN can end with an X. If that's the case, it represents `10`. If the X appears anywhere else, the ISBN is invalid.
- ISBNs may be written with or without hyphens.
- Any other characters make the ISBN invalid.

## Instructions

Create a function `isValidIsbn(isbn)` that takes a string and determines if it's a valid ISBN.
