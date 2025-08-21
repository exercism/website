# Solve the Maze

The first exercise you solved was manually moving your character around the maze. Already in Level 3, you're ready to solve any maze programmatically using code!

To make that possible, we're giving you three new functions:

- `can_turn_left()`: returns `true` if the space to the character's left is not a wall.
- `can_turn_right()`: returns `true` if the space to the character's right is not a wall.
- `can_move()`: returns `true` if the space ahead of the character is not a wall.

With those three functions and the `move()`, `turn_left()` and `turn_right()` you had in Level 1, you can solve any maze.

Spend a little time trying to work out how (maybe 15-30 minutes). Treat it as a fun logic puzzle. Get some paper and draw things out. Then when you want to check your method (or if you give up), read the instructions below

<hr class="border-borderColor5" style="margin:80px 0"/>

## Instructions

You can solve all the mazes using the following method (this is what we call an "algorithm" - a method of solving a problem):

- If you can turn left, turn left and move forward
- Otherwise, if you can move forward, move forward.
- Otherwise if you can turn right, turn right and move forward.
- Otherwise turn around

This exercise is broken into different tasks. Follow the instructions below and as you completed each task, one or more the scenarios will complete, and more instructions will appear below!
