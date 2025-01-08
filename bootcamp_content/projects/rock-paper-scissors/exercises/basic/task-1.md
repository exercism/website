# Task 1

There are a few different ways to approach this exercise, but let's solve it by breaking it down based on player 1's choice.

To start with, return the correct value based on when player 1 choices "paper":

- If player 2 also chooses paper, we should return `"tie"`
- If player 2 chooses "rock", then the paper smoothers the rock so player 1 wins (return `"player_1"`)
- If player 2 chooses "scissors", then the rock blunts the scissors so player 2 wins (return `"player_2"`)
