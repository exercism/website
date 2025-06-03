# Ticky Tac

Welcome to Tic Tac Toe in JavaScript.

Some of you will have solved this in JikiScript in Part 1, with a few extra bells and whistles (including an "AI" opponent). For now, we're stripping it back a bit and focussing again on the game fundamentals!

By the end of this exercise you should have a working game that you can play against a friend!

If you don't know it, Tic Tac Toe is a classic game that is played all over the world. You might also know it as "naughts and crosses".

Two players take turns to draw an x or o on a 3x3 gameboard. Get 3 in a row (horizontal, vertical, or diagonal) and you win!

## Instructions

Your job is to implement the basics of the game. You should create a 3x3 grid with interactive squares. Players should be able to click on a square to play their "x" or "o" and the turn should change automatically.

If a player gets three in a row, that line should highlight in purple and the game should be over.

If all the squares are taken, the boxes should go grey and faded, and the game should also end.

Clicking on squares that are already taken should have no impact.

Experiment with the Example implementation, and try and get yours to match it as closely as possible!

### Notes

My implementation is quite straight-forward. The only thing you might find useful to know is that I used `20vmin` units for the font-size of the `x` and `o`.

The colors I used were `#aaa`, `purple`, `#ddd` and `#666`.
