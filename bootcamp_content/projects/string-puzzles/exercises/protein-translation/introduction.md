# Protein Translation

Let's go deeper with the microbiology (you're getting two courses for the price of one!)

RNA can be broken into three-nucleotide sequences called codons, and then translated to a protein like so:

1. If we have **RNA**: `"AUGUUUUCU"`
2. We translate it to **Codons**: `"AUG", "UUU", "UCU"`
3. And then into **Protein**: `"Methionine", "Phenylalanine", "Serine"`

There are 64 codons which in turn correspond to 20 amino acids.
However, for this exercise, we're only working with a small subset of the codon sequences.
After all, if your program works for one codon, the program should work for all of them!

## Details

There are also three terminating codons (also known as 'STOP' codons).
If you encounter any of these codons, all translation ends and the protein is terminated.

For example, `"UAA"` is a STOP codon, so any codons after it are ignored:

- RNA: `"AUGUUUUCUUAAAUG"` =>
- Codons: `"AUG", "UUU", "UCU", "UAA", "AUG"` =>
- Protein: `"Methionine", "Phenylalanine", "Serine"`

(Note that the AUG is not translated into the final methionine).

Below are the codons and resulting amino acids needed for the exercise.

| Codon              | Amino Acid    |
| :----------------- | :------------ |
| AUG                | Methionine    |
| UUU, UUC           | Phenylalanine |
| UUA, UUG           | Leucine       |
| UCU, UCC, UCA, UCG | Serine        |
| UAU, UAC           | Tyrosine      |
| UGU, UGC           | Cysteine      |
| UGG                | Tryptophan    |
| UAA, UAG, UGA      | STOP          |

## Instructions

Your task is to write a function `translate_rna` that takes in an RNA sequence, and returns the list of Animo Acids.

For example, if we ran the code `translate_rna("AUGUUUUCUUAAAUG")`, we'd expect your function to return `["Methionine", "Phenylalanine", "Serine"]`.

### Functions

You have two functions available:

- `push(list, element)`: This adds an element to a list, then returns the new list. (e.g. `push(["a"], "b") → ["a", "b"]`)
- `join(string1, string2)`: This takes two strings as inputs and returns a new string with them joined together.
