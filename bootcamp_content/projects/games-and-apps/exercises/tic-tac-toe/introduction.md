# Tic Tac Toe

Welcome to Tic Tac Toe - your **first major project.**

This exercise brings together everything you've learnt so far: variables, functions, conditionals, looping, and different data types.
And it lets you build something from scratch!

This isn't necessarily harder than the exercises you've solved already, but it is more involved.
You're going to write well over 100 lines of code and build something largely from scratch.
That's a huge thing to be doing after only a few weeks of learning coding, so be kind and compassionate to yourself as you do it, and appreciate that this might take time to get right.

Unlike the normal exercises, it's not intended that you complete this in a single week.
I'd much rather you took your time, calmly working through it than trying to rush it.
I'd also encourage you to really spend time thinking about the various problems you might hit.
Reach out for help if you need it, but let things percolate for a while first.
It might be that you really just get stuck on something and come back to it in a couple of weeks once you've had more practice at things.
That's fine if so!

One of the aims is to write code that you're proud of.
It's possible to build a very pleasant-to-read version of this exercise.
You definitely don't want to try and get this in as few lines as possible - you want to focus on code quality and readability over succinctness.
That said, if you get a solution that's in the region of 170 lines of code, you probably have a nice, clean solution.

## Game Rules

In Tic Tac Toe (also known as Noughts and Crosses in England!), one player is `o` and one player is `x`, and you take turns to write your symbol in one of the squares of a 3x3 grid.

If you place three of your symbols in a row (either horizontally, vertically, or diagnoally) then you win! If all spaces get taken without three in a row, the game is a draw.

## Instructions

Your job is to create a `run_game` function.

It has one input `moves`, which is a list of coordinate pairs (e.g. `[[1,2], [3,2]]` means that the first player places a piece in the second column of the first row, then the next player places a piece in the second column of the third row).

That function should create a game board then place each of the pieces specified in the moves. As it does so, it should check whether each move is valid, and announce a winner if appropriate.

Sometimes a move might be a `"?"` instead of a coordinate pair.
In these situations, you decide what move to play:

- If you can win, you win.
- If you can block your opponent's win, you do so.
- Otherwise place a piece wherever you think is sensible.

There are no game functions provided.
You have to write the whole thing from scratch!

### Drawing

In this exercise, rectangles and circles are filled white by default.
They have an outline (known as a "stroke") that you can control, by setting its width and its color.
We've also added a `line` function that draws a line between two points.
Lines must be drawn from left to right for the checks to pass.

### Writing

This exercise asks you to write to the screen for the first time.

**Whenever** you're asked to write below, you should:

- Draw a box from 0,0 to 100,100. Unless specified it should be filled with an rgba value of red: 96, green: 79, blue: 205, and the alpha channel set to 0.85.
- Use the new `write` function, which writes big text to the center of the screen in white ink.

### The Board

The first thing you should do is draw a board.
It is made up of two things:

1. A rectangle from 5,5 to 95,95.
2. A series of grid lines divide the board equally into 9.

All the lines should be drawn with a stroke width of 1 and a pen color of your choice.

### Pieces

You draw the pieces as a circle and cross of two lines.

- All pieces should be placed in the center of the squares.
- The circles should have a radius of 10.
- The crosses should be two lines, spanning 20 in both directions.

Together the board and the pieces should look something like this:

<img src="https://assets.exercism.org/bootcamp/graphics/tic-tac-toe-pieces.png" style="width: 100%; max-width:300px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

### Making moves

- The first move should always be an `o`
- Moves should alternate between `o` and `x`
- If a player makes an invalid move, you should:
  - Write `"Invalid move!"` with a background of red: 200, green: 0, blue: 0, and alpha: 0.85.
  - Stop processing moves.

### Draws

If the game board fills without a winner, you should:

- Turn all the x's and o's to a light grey.
- Write `"The game was a draw!"`

### Winning

If either player gets 3 in a row, you should:

- Highlight the winning row in `"#604fcd"`.
- Turn all the other x's and o's to a light grey.
- Write either `"The x's won!"` or `"The o's won!"`.

The resulting situation should be something like this:

<img src="https://assets.exercism.org/bootcamp/graphics/tic-tac-toe-won.png" style="width: 100%; max-width:300px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

### Incomplete Games

Some scenarios have incomplete games, where there's not yet a winner and the game is not yet a draw.
In those situations you should not show the results screen.
Leave the game in the state where another move could be made.

### Play the game in order.

The scenarios expect you to play the game out in order.
Make each move on the board, then deal with the final state at the end.

## Functions Available

You have a few functions available:

### List functions

- `push(list, elem)`: Adds an element to an list and returns a new list.
- `concatenate(str1, str2, ...)`: Concatenates 2 or more strings together and returns the new string.

### Drawing functions

- `fill_color_rgba(red, green, blue, alpha)`: Changes the fill color to an rgb color with an alpha channel. 0 means transparent, 1 means opaque.
- `stroke_color_hex(hex)`: Changes the stroke color to a hex or HTML color.
- `stroke_width(width)`: Changes the stroke width to the specified number.
- `circle(cx, cy, radius)`: Draws a circle at the point specified by (cx, cy) with the given radius.
- `rectangle(top, left, width, height)`: Draws a rectangle by specifying the top, left, width and height.
- `line(x1,y1, x2, y2)`: Draws a line from x1,y1 to x2,y2.
- `write(text)`: Writes whatever text is provided to the center of the screen in white ink.
