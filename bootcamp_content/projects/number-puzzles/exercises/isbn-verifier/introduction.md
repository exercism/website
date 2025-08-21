# Description

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

## Library Functions

There are lots of ways to solve this, but you maybe find it helpful to include your [`my#length`](/bootcamp/custom_functions/length/edit) and [`my#contains`](/bootcamp/custom_functions/contains/edit) library functions.

## Functions

You have two functions available to you:

- `string_to_number(str)`: Takes a string and returns it converted to a number. The string must only contain digits.
- `push(list, element)`: This adds an element to a list, then returns the new list.
