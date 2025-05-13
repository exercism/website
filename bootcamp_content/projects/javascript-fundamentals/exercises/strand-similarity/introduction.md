# Hammming

This is the same exercise as Hamming exercise in Coding Fundamentals and on Exercism. Can you solve it idiomatically in JavaScript?

This is a classic Exercism exercise and one of a couple about molecular biology (what Katrina - Exercism's co-founder's degree was in!)

Your body is made up of cells that contain DNA.
Those cells regularly wear out and need replacing, which they achieve by dividing into daughter cells.
In fact, the average human body experiences about 10 quadrillion cell divisions in a lifetime!

When cells divide, their DNA replicates too.
Sometimes during this process mistakes happen and single pieces of DNA get encoded with the incorrect information.
If we compare two strands of DNA and count the differences between them, we can see how many mistakes occurred.
This is known as the "Hamming distance".

The Hamming distance is useful in many areas of science, not just biology, so it's a nice phrase to be familiar with!

## Instructions

Your task is to calculate the Hamming distance between two DNA strands.

To do this, you need to read DNA using the letters C, A, G and T.
Two strands might look like this:

    GAGCCTACTAACGGGAT
    CATCGTAATGACGGCCT
    ^ ^ ^  ^ ^    ^^

They have 7 differences, and therefore the Hamming distance is 7.

Create a function called `hammingDistance` that has two inputs: the two DNA strands as strings.
It should return a number as the distance.

Both DNA strands will always be the same length.
