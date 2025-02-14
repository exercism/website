# Omniscience

Last time you used the `look` function to move around the maze.
Now we're removing that function from you too!

In this exercise, you get to see the whole maze as a a grid of 9 rows, each containing 9 cells.

For example, your maze might look like this.
We use `^` to mean the start, `$` to mean the end, `x` to mean a wall and `-` to mean a space.

```
x ^ x x x x x x x x
x - - x x x x - - $
x x - x x x x - x x
x - - x x - x - x x
x x - - - - x - x x
x x - x x x x - x x
x x - x x x x - x x
x x - - - - - - x x
x x x x x x x x x x
```

Each scenario has a different maze.

We've given you your code from the previous exercise.

Your job is to navigate the maze from start to finish using this new information, rather than using the `look()` method.

### Functions

We have given you a function called `get_maze()` which returns the maze as a list of lists.

If the scenario was about he Maze above, `get_maze()` would return:

```
[
    ["x", "^", "x", "x", "x", "x", "x", "x", "x", "x"],
    ["x", "-", "-", "x", "x", "x", "x", "-", "-", "$"],
    ["x", "x", "-", "x", "x", "x", "x", "-", "x", "x"],
    ["x", "-", "-", "x", "x", "-", "x", "-", "x", "x"],
    ["x", "x", "-", "-", "-", "-", "x", "-", "x", "x"],
    ["x", "x", "-", "x", "x", "x", "x", "-", "x", "x"],
    ["x", "x", "-", "x", "x", "x", "x", "-", "x", "x"],
    ["x", "x", "-", "-", "-", "-", "-", "-", "x", "x"],
    ["x", "x", "x", "x", "x", "x", "x", "x", "x", "x"]
]
```

You also still have your movement functions from previous exercises:

- `move()`
- `turn_left()`
- `turn_right()`

It might be important to know that your character always starts facing downwards.

---
