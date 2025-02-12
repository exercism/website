# Tic Tac Toe

## Game Rules

In Tic Tac Toe, one player is `o` and one player is `x`, and you take turns to write your symbol in one of the squares of a 3x3 grid.

If you get place three of your symbols in a row (either horizontally, vertically, or diagnoally) then you win! If all spaces get taken without three in a row, the game is draw.

## Implementation Rules

Here are the rules to follow

Playing pieces:

- Moves should alternative between `o` and `x`
- The first move should always be an `o`
- If a player makes an invalid move, you should use the `error_invalid_move()` function, which shows a error message, and then not do anything further.

- Board

  - The board starts at 5,5 and has a width and height of 90.
  - The grid lines divide the board equally into 9.

- Pieces
  - All pieces should be placed in the center of the squares.
  - The circles should have a radius of 10
  - The crosses should be two lines, spanning 20 in both directions.
