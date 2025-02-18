# Determine Winner

To start our game of Rock, Paper, Scissors, we're going to write some code to determine the winner.

In Rock, Paper, Scissors, two players each choose rock, paper or scissors. You then compare the choices to see who's won:

- If both players choose the same, it's a tie.
- Rock blunts scissors (rock wins).
- Scissors cut paper (scissors wins).
- Paper smothers rock (paper wins).

Your job is to compare the choices the players have made and announce the winner to the playing hall.

### Functions

You have three functions to use:

- `get_player_1_choice()`: Returns player 1's choice - one of `"rock"`, `"paper"` or `"scissors"`.
- `get_player_2_choice()`: Returns player 2's choice. Also `"rock"`, `"paper"` or `"scissors"`.
- `announce_result(result)`: You announce the result, using one of `"player_1"`, `"player_2"`, or `"tie"` as an input.

### How to use the functions

In case its not clear how to use the functions, imagine this parallel universe where if player 1 chooses `"paper"`, the game is always a tie. In that situation you could write the following code:

```jikiscript
if(get_player_1_choice() == "paper") do
  announce_result("tie")
end
```

### Bonus Challenges

Want some extra practice?

- Can you solve the exercise only using the `get_player_1_choice()` and `get_player_2_choice()` functions once in your program (imagine how inefficient it is to have to keep running a whole machine to get the player's choices over and over again).
- Can you solve the exercise with `announce_result(...)` only appearing once in your code?
- Can you solve the exercise using the first two bonus conditions and only 13 lines of code (not including blank lines or comments)?
