# Task 2

Great, now let's consider what happens if player 1 chooses "rock':

- If player 2 also chooses rock, we should return `"tie"`
- If player 2 chooses "paper", then the paper smoothers the rock so player 2 wins (return `"player_2"`)
- If player 2 chooses "scissors", then the rock blunts the scissors so player 1 wins (return `"player_1"`)
