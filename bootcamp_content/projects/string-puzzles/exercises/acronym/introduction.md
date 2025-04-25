# Acronym

This is another classic Exercism exercise where your job is to convert a phrase into its acronym.

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

### Functions

For this exercise, you have two functions available:

- `concatenate(str1, str2, ...)`: Takes 2 or more strings and return them combined into one.
- `to_upper_case(str)`: This takes a string and returns its uppercase equivalent (e.g. it turns `"frog"` into `"FROG"`).

### A little tricky?

Some people find this one quite tricky!

With the right tools, you can solve this exercise in only 3 lines of code. Right now though, you don't have those tools at your disposal and so you're more likely to need to write 20 or 30 (or more!) lines of code.

**Once you've finished**, if you'd like to see some more elegant ways of solving this and learn about Regular Expressions (a special type of language for parsing text) [watch this video](https://www.youtube.com/watch?v=ofzqp4MFHvM&ab_channel=Exercism).

### Hints

Click to expand.

<details>
<summary>Hint 1</summary>

You don't need 26 if/else statements to check whether something is a letter.
How could you use something you learnt in Level 5 to do it a better way?

</details>

<details>
<summary>Hint 2</summary>

`"a"` is not the same as `"A"`. You don't really care about whether a letter is lowercase or uppercase when working out what the acronym is, but you do need to consider case a lot during the exercise.

</details>
