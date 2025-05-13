# Stormy Sounds

In Coding Fundamentals of the course, we solved the Classic Exercism exercise Raindrops, which is based on FizzBuzz.

If you took part in Coding Fundamentals, try and refine your code to make it a little slimmer and slicker. If you're new to the exercise, have fun solving.

## Instructions

Your task is to convert a number into its corresponding sounds.

We do this by seeing what the number is divisble by (e.g. the number 10 is divisble by 1, 2, 5 and 10. The number 12 is divisible by 1, 2, 3, 4, 6 and 12).

If a given number:

- is divisible by 3, add `"Pling"` to the result.
- is divisible by 5, add `"Plang"` to the result.
- is divisible by 7, add `"Plong"` to the result.
- is not divisible by 3, 5, or 7, the result should be the number as a string.

You need to create a function called `stormySounds` that takes the number as an input and returns its Raindrops sounds.

### Examples

- We would expect `stormySounds(28)` to return `"Plong"` because 28 is divisible by 7, but not 3 or 5.
- We would expect `stormySounds(30)` to return `"PlingPlang"` because 30 is divisible by 3 and 5, but not 7.
- We would expect `stormySounds(34)` to return `"34"` because 34 is not divisible by 3, 5, or 7.
