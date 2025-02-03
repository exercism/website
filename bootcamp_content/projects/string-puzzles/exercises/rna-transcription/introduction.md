# RNA Transcription

Our second molecular biology exercise looks at RNA as well as DNA!

# Introduction

You work for a bioengineering company that specializes in developing therapeutic solutions.

Your team has just been given a new project to develop a targeted therapy for a rare type of cancer.

It's all very complicated, but the basic idea is that sometimes people's bodies produce too much of a given protein.
That can cause all sorts of havoc.

But if you can create a very specific molecule (called a micro-RNA), it can prevent the protein from being produced.
This technique is called [RNA Interference][rnai].

[rnai]: https://admin.acceleratingscience.com/ask-a-scientist/what-is-rnai/

## Instructions

Your task is to determine the RNA complement of a given DNA sequence.

Both DNA and RNA strands are a sequence of nucleotides.

The four nucleotides found in DNA are adenine (**A**), cytosine (**C**), guanine (**G**), and thymine (**T**).

The four nucleotides found in RNA are adenine (**A**), cytosine (**C**), guanine (**G**), and uracil (**U**).

Given a DNA strand, its transcribed RNA strand is formed by replacing each nucleotide with its complement:

- `G` -> `C`
- `C` -> `G`
- `T` -> `A`
- `A` -> `U`

Create a function called `dna_to_rna(dna)`.
It should take a DNA string as it's input, and should return a string representing the RNA equivelent.

### Functions

For this exercise, you have one function available:

- `join(str1, str2)`: This takes two strings and outputs them joined together.

#### Emojis

That last two scenarios are weird ones, aren't they... Any ideas what's going on?

It turns out that lots of emojis are acutally made up of other emojis joined together with hidden (zero width) spaces.

In the first example, the family emoji (👩‍👩‍👧‍👦) is made up of two women and two women (👦‍👧‍👩‍👩). When it's reversed you can see the individual characters.

In the second example we have a rainbow and a flag (🌈‍️🏳), but when we reverse the order to get the flag then the rainbow, it becomes a rainbow flag! (🏳️‍🌈️).
