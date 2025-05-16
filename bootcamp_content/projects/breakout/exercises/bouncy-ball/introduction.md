# Boundaried Ball

Welcome to Breakout!

This was one of my favourite games a kid, and I'm very excited to make it with you here!

In Part 1, we're going to think out all the logic of the game and build components of it.
Then in Part 2, we'll build a fully fleshed out version!

## Moving the Ball

Our adventure starts with the ball.

In previous exercises, we've made a ball by drawing a circle.
Now we move into Object Oriented world, we can think more of the Ball as it's own solid thing.

We've create a `Ball` class (blueprint) for you.

- It has a constructor that takes no inputs.
- You need to create an instance of the ball (an object).
- That instance will have an internal `cx` and `cy`, specifying the center of the ball, which you can read but not change.
- It will have a property called `radius` that you can read.
- It will have an `x_velocity` and `y_velocity`, which you can read **and** change.
- When you create the instance, the ball will be drawn on screen.

You also have a function called `move_ball(ball)`, which takes an instance of a ball as its input, and moves it in in accordance with the `x_velocity` and `y_velocity`
It change the ball's internal state, and also move it on the screen.

The game area ranges from 0 to 100 in both directions.

## Instructions

Your job is to move the ball around the game area, detecting when it hits a wall, and then changing its velocity in the opposite direction.
The velocities should always be `1` or `-1`.
The ball should never overlap the edge of the game area.

If you do everything correctly, the ball will move in a perfect diamond continuously.

Once the ball has moved around the wall twice and reached its initial starting position, it should stop.
