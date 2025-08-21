# Acronym

Like "Etiquette Evening", this is a JikiScript exercise from Coding Fundamentals (its known there as "Acronym"). If you took part in Coding Fundamentals, I recommend using your solution there as a reference, and "translating" it into JavaScript! If you're new to the course, then have fun solving this as a new exercise.

Your job is to convert a phrase into its acronym.

Techies love their TLA (Three Letter Acronyms), so being able to quickly turn long name like Portable Network Graphics to its acronym (PNG) is a pretty nice ability to have.

Your job is to create a function `acronym` that takes a string as an input, and returns its acronym as a string.

You should:

- Treat spaces as word seperators
- Treat hyphens (`-`) as word separators
- Ignore all other punctuation

Some examples:

| Input                     | Output |
| ------------------------- | ------ |
| As Soon As Possible       | ASAP   |
| Liquid-crystal display    | LCD    |
| Thank George It's Friday! | TGIF   |

### String Functions

In this exercise, you'll be using strings, and it may be useful to be familiar with some of the properties and methods you can use.
You can see all string methods [on MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String).

Depending on your approach, the `toLowerCase()`, `toUpperCase()`, `charCodeAt()` or `includes()` methods might be particuarly useful.
