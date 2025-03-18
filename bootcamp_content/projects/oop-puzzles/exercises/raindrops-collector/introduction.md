# Raindrops

A long time ago you solved Raindrops - a classic coding challenge.

Now you're taking this to the next level by creating a `RaindropsCollector` class. This class is slightly more advanced as it can catch multiple splatters of rain.

The class needs to have two methods:

- `add_number(number)`: Adds a new number into it's calculations
- `get_sounds()` Returns the sounds the numbers should make as a string.

As a reminder, previously you followed these rules. If a given number:

- is divisible by 3, add `"Pling"` to the result.
- is divisible by 5, add `"Plang"` to the result.
- is divisible by 7, add `"Plong"` to the result.
- is not divisible by 3, 5, or 7, the result should be the number as a string.

We're modifying things slightly now.

- Firstly, if the number is not divisible by 3, 5 or 7, just ignore the number - don't add it to the result.
- Secondly, the `RaindropCollector` can store multiple numbers. It should add their sounds together. So if we have the number 3 and then the number 105, we should write out `"PlingPlingPlangPlong"` (The first `"Pling"` for 3 and the the rest for 105).

## Instructions

Create the `RaindropsCollector` class.

We've provided you your old code as reference but everything should be moved inside a class.

## Functions

You have two function available:

- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)
