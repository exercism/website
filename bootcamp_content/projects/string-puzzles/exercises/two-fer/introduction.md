# Two Fer

This is a classic Exercism exercise and is generally the "warm-up" exercise on each of Exercism's language tracks.

In some English accents, when you say "two for" quickly, it sounds like "two fer".
Two-for-one is a way of saying that if you buy one, you also get one for free.
So the phrase "two-fer" often implies a two-for-one offer.

Imagine a bakery that has a holiday offer where you can buy two cookies for the price of one ("two-fer one!").
You take the offer and (very generously) decide to give the extra cookie to someone else in the queue.

## Instructions

Your task is to determine what you will say as you give away the extra cookie.

If you know the person's name (e.g. if they're named Do-yun), then you will say:

```
One for Do-yun, one for me.
```

If you don't know the person's name, you will say _you_ instead.

```
One for you, one for me.
```

Here are some examples:

| Name   | Dialogue                    |
| :----- | :-------------------------- |
| Alice  | One for Alice, one for me.  |
| Bohdan | One for Bohdan, one for me. |
|        | One for you, one for me.    |
| Zaphod | One for Zaphod, one for me. |

### The Task

Write a function called `two_fer`.

- It should accept a string representing someone's name as an input.
- If there is no name, the string will be empty.
- It should return a string with the correct dialog.

Note: The words "Bob" or "Alice" should **not** appear in your code!

### Functions

There is one function available in this exercise

- `concatenate(string_1, string_2, ...)`: This joins two or more strings together and returns the result. It has infinite possible inputs and will only use the ones you ask it to!

## Explore multiple Approaches

This exercise has a few different ways it can be solved.
Explore to see if you can come up with at least two approaches.
