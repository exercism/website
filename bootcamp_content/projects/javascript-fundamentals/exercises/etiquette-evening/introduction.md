# Formal Dinner

This is a JikiScript exercise from Coding Fundamentals (its known there as "Formal Dinner"). If you took part in Coding Fundamentals, I recommend using your solution there as a reference, and "translating" it into JavaScript! If you're new to the course, then have fun solving this as a new exercise.

You're back in your side hustle as a bouncer.
It's the evening after the After Party, and there's yet another shindig.
This time it's a formal dinner.

This definitely isn't the place to use **just** your first name.
In fact it isn't the place to use your first name at all.
Here, everyone goes by an honorific (Miss, Mr, Dr, etc) and their surname.

Once again, though, your list of names is just people's full names.
So when Mr Pitt turns up, you need to work out that this is the "Brad Pitt" on your guest list.

## Instructions

Write a function called `onGuestList`.
The function has two inputs.
The first will contain the guest list as a list of strings.
The second is the name of the person formatted as honorific and a surname.
You should return a boolean specifying whether the person is on the guest list.

For this task, you can presume that honorifics will always be one word.

### String Methods

In this exercise, you'll be using strings, and it may be useful to be familiar with some of the properties and methods you can use.
You can see all string methods [on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).

Take a specific look at `length` property and the `endsWith()` method. You might also find the `split()` method helpful.

### Array Methods

Depending on your approach, you might be interested in looking at a few Array methods - for example, `slice()` and `join()`.
You can see all array methods [on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array) too.
