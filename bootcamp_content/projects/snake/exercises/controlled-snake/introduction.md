# Slithery Snake

Welcome to Part 2 of building Snake.

In this exercise, we're adding two new elements:

1. The ability to control the snake using the keyboard
2. Game over criteria for both the wall edges and the snake eating itself.

## Instructions

### Movement

Your first job is to move the snake using the arrow keys.
**Remember**, you have to give focus to the Output window by clicking on it before the keys will work!

One thing to consider is that if you press two keys before the snake moves, the snake should ignore the first key press (try on the Example quickly pressing two directions and note how only the later one is honoured).

### Game Edges

If the snake hits the edge of the game area, the screen should go `darkred` and the game should end.

### Self-eating snake

One of the key game mechanics of Snake is that the snake can't eat its own tail. Add functionality so if the snake's head moves into a square that contains the snake's tail, the game will end.

Note, you also shouldn't be able to move back directly in the direction you're moving. So if you're moving right-to-left and you press the right arrow key, the game should also end.

Unsure of the rules? Play the example game!

Have fun!
