# Boundaried Ball

In this exercise we're going to make your nascent Breakout game playable!

Your job is to add a paddle, which moves as you move your mouse around the screen. The ball should bounce off it, and the game should stop if the ball hits the ground.

## The `getBoundingClientRect()` method

For this exercise, you might want to use the [`getBoundingClientRect()` method](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect). You can call it on any DOM Element, and that will give you back a [`DOMRect` object](https://developer.mozilla.org/en-US/docs/Web/API/DOMRect) with properties like `left` and `width`.

This allows you to work out in pixel values the left and width of your game area (or other components), which might be helpful in understanding where the mouse is relative to the game area.

## Instructions

There's a few steps involved in this:

1. Add a paddle. My version uses percentages for sizing and pixels for the border radius. It sits just off the bottom.
2. Change the ball to start on the paddle.
3. Add logic to ensure the ball bounces off the paddle.
4. If the ball hits the bottom, change the screen to be dark red, give the non-ball elements an opacity of 0.2 (via the style property), and stop the game.
5. Allow the paddle to move in line with your mouse movements.

Spend a couple of minutes experimenting with the Expected solution to get a feel for how everything should work!

Have fun!
