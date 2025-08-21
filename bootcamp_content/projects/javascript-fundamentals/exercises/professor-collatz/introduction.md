# Introduction

This is the same exercise as Collatz Conjecture in Coding Fundamentals and on Exercism. Can you solve it idiomatically in JavaScript?

One evening, you stumbled upon an old notebook filled with cryptic scribbles, as though someone had been obsessively chasing an idea.
On one page, a single question stood out: **Can every number find its way to 1?**
It was tied to something called the **Collatz Conjecture**, a puzzle that has baffled thinkers for decades.

The rules were deceptively simple:

1. Choose a number.
2. If it's even, divide it by 2.
3. If it's odd, multiply it by 3 and then add 1.
4. Repeat 2-4 with the result, continuing indefinitely.

### An example

Curious, you chose the number 12 to test, and began the journey:

```
12 ➜ 6 ➜ 3 ➜ 10 ➜ 5 ➜ 16 ➜ 8 ➜ 4 ➜ 2 ➜ 1
```

Counting from the second number (6), it took 9 steps to reach 1, and each time the rules repeated, the number kept changing.
At first, the sequence seemed unpredictable — jumping up, down, and all over.
Yet, the conjecture claims that no matter the starting number, **we'll always end at 1.**

It was fascinating, but also puzzling.
Why does this always seem to work?
Could there be a number where the process breaks down, looping forever or escaping into infinity?
The notebook suggested solving this could reveal something profound — and with it, fame, [fortune][collatz-prize], and a place in history awaiting whoever could unlock its secrets.

## Instructions

Create a function called `collatzSteps` that takes one input, a number. Return **how many steps** it takes to get from any given number, to 1, following the rules of the Collatz Conjecture.

To loop a certain amount of times you can use this syntax.

```
for(let i = 0; i < 200; i++) { }
```

You can also use `while(true) {}` but there's a good chance you'll end up crashing your browser with a bug!

[collatz-prize]: https://mathprize.net/posts/collatz-conjecture/
