# Hot Zones

In this exercise, we're going to make the ball and paddle interactions a little more interesting.

In breakout, where you hit the ball with paddle matters.
The further away from the center you hit the ball, the faster the ball gets. And if you hit it right on the edges the ball bounces back in the direction it came from!

## Instructions

Implement the following rules!

### Speed

Speed means how far the ball moves in each requestAnimationFrame. The following values are scaled to my machine. If you have a different refresh rate to me and the game seems too fast or slow, you may wish to scale your speeds. Try and get it about the same as the gif at the bottom of the instructions.

In this exercise we start to treat the speed on the x axis (left-right) and on the y axis (top-bottom) differently.

**Vertical Speeds**

- The starting vertical speed should be 0.5.
- Vertical speeds increase and decreate relative to the existing vertical speed.
- If the center of the ball hits the center of the paddle, it should reduce its vertical speed by half.
- If the center of the ball hits the edge of the paddle, it should increase its vertical speed by half.
- If it hits anywhere between those points, it should change its vertical speed as a percentage of its existing speed in a linear manner (i.e. if it hits half way between center and the left edge, it would keep the same speed. If it hits a little to the left of that, it would speed up slightly. If it hits a little to the right, it would slow down slightly).
- The vertical speed should never go above 1.5.
- The vertical speed should never go below 0.5.

**Horizontal Speeds**

- The starting horizontal speed should be 0.5.
- Horizontal speeds change to new values every time the paddle hits, irrespective of their previous values.
- If the center of the ball hits the center of the paddle, it should change its horizontal speed to be 0.
- If the center of the ball hits the edge of the paddle, it should change its horizontal speed to be 1.
- If it hits anywhere between those points, it should change its horizontal speed in a linear manner (i.e. if it hits half way between center and the left edge, it would change to have a speed of 0.5. If it hits a little to the left of that, it might be 0.6. If it hits a little to the right, it might be 0.4).

### Direction

The ball should continue to bounce as it currently does most of the time.

However, if the center of the ball is travelling left to right, and hits the left quarter of the paddle, it should bounce back to the left.

Similarly, if the center of the ball is travelling from right to left, and hits the right quarter of the paddle, it should bounce back to the right.

### Example

Watch the following gif to see an example game.

<img src="https://assets.exercism.org/bootcamp/graphics/breakout-bounce.gif" style="width: 100%; max-width:400px;margin-top:10px;margin-bottom:20px;border:1px solid #ddd;border-radius:5px"/>

Also - remember to play the Example game and see if it feels the same as yours!

Have fun!
