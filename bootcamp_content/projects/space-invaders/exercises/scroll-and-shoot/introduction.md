# Space Invaders

Welcome to the first Space Invaders exercise. This is a classic 1970s game, and one of the first I ever played!

By the end of the Bootcamp you'll have built this from scratch. But for now, your job is to play and win the game, by shooting down all the aliens.

You can move the laser left and right using the `move_left()` and `move_right()` functions. You can experiment to see how far left and right you can move. If you go off the edge of the screen, you lose.

As you move, you need to check whether there's an alien above you using the `is_alien_above()` function and then `shoot()` it if so. If you shoot when there's not an alien, you'll lose the game - wasting ammo is not allowed!

The laser canon easily overheats.
You need to move between shoots to keep it cool.

Once all the aliens have been shot down, you win!

## Functions

You have the following functions available.

- `move_left()`: Moves the laser to the left
- `move_right()`: Moves the laser to the right
- `is_alien_above()`: Returns `true` if there's an alien directly above you, or `false` if not.
- `shoot()`: Shoots upwards.

You'll also need the `set`, `change`, `if` and `repeat_until_game_over` concepts.

To start with, you might find it better to use `repeat` with a fixed number of times, so that your code doesn't run forever.

## There's many ways to solve this!

We've now entered the point of the course where there are **lots** (probably hundreds) of ways to solve this exercise. There are different tradeoffs between different approaches. Over time you'll learn "best practices" and why some ways are better than others, but for now don't get hung up on that. Your job is **just to solve the exercise**.

In the Labs sessions I'll start discussing different ways to solve things, and you can tell me about what approach you took!

## Hints

As normal, it's important to break the exercise down into steps. You probably want to get the laser moving from side to side first, then add the logic for detecting and shooting aliens afterwards.

Much of the logic is similar to the rainbow ball exercise, but it's a little different as you aren't moving using coordinates. You'll need to use different variables and take a slightly different approach, but the core logic of keeping track of where you are is the same.
