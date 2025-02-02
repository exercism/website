# Two Fer

This is another classic Exercism exercise where your job is to convert a phase into its acronym.

Techies love their TLA (Three Letter Acronyms), so being able to quickly turn long name like Portable Network Graphics to its acronym (PNG) is a pretty nice ability to have.

Your job is to create a function `acronym` that takes a string as an input, and returns its acronym as a string.

You should:

- Treat spaces as word seperators
- Treat hyphens (`-`) are word separators
- Ignore all other punctuation

Some examples:

| Input                     | Output |
| ------------------------- | ------ |
| As Soon As Possible       | ASAP   |
| Liquid-crystal display    | LCD    |
| Thank George It's Friday! | TGIF   |

### Functions

For this exercise, you have three functions available:

- `join(str1, str2)`: This takes two strings and outputs them joined together.
- `to_upper_case(str)`: This takes a string and returns its uppercase equivelent (e.g. it turns `"frog"` into `"FROG"`).
- `lowercase_latin_alphabet`: This returns a list of the all the lowercase latin letters (`["a","b","c"...]`)

### Hints

Click to expand.

<details>
<summary>Hint 1</summary>

`"a"` is not the same as `"A"`. You don't really about whether a letter is lowercase or uppercase when working out what the acroynm is, but you do need to consider case a lot during the exercise.

</details>
