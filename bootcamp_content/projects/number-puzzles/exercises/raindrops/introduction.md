# Raindrops

Raindrops is a version of the classic FizzBuzz challenge.
This is a programming exercise that's been used in interviews forever.

Your task is to convert a number into its corresponding raindrop sounds.

We do this by seeing what the number is divisible by (e.g. the number 10 is divisible by 1, 2, 5 and 10. The number 12 is divisible by 1, 2, 3, 4, 6 and 12).

If a given number:

- is divisible by 3, add `"Pling"` to the result.
- is divisible by 5, add `"Plang"` to the result.
- is divisible by 7, add `"Plong"` to the result.
- is not divisible by 3, 5, or 7, the result should be the number as a string.

## Instructions

You need to create a function called `raindrops` that takes the number as an input and returns its Raindrops sounds.

To solve this, you need two functions:

- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `number_to_string(number)` takes a number as an input and returns it magically changed into a string.

### Examples

- We would expect `raindrops(28)` to return `"Plong"` because 28 is divisible by 7, but not 3 or 5.
- We would expect `raindrops(30)` to return `"PlingPlang"` because 30 is divisible by 3 and 5, but not 7.
- We would expect `raindrops(34)` to return `"34"` because 34 is not divisible by 3, 5, or 7.

## Hints

Have a good go first, but if you get stuck, check out these hints!
Click to expand.

<details><summary>Can't get <code>"PlingPlangPlong"</code>? Got more than 4 <code>if</code> statements?</summary>

The key to this exercise is to **accumulate** the sounds as you work through the `if` statements. You don't want to `return` straight away as you find sounds. Instead build up the resulting string.

This whole exercise should really only have one or two return statements.

</details>
