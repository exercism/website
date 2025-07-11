# Maze Promises

In the very first exercise of the Bootcamp, students (maybe you!) had to give instructions to a little blob to solve a maze. You had various commands like `move()` and `turn_left()`. In this exercise, you're going to recreate that whole exericse yourself!

## Instructions

This exercise is designed to be solved in quite a specific way.
Please read the instructions carefully.

The HTML has been provided with some basic CSS.

You should:

- Change the CSS to use variables.
- Create a `move()` function that moves the blob by setting changing a variable that powers its top/left
- Make the movement smooth using a CSS transition (.e.g. adding `transition: all 1s` to the `#blob`).
- Make use of the `transitionend` event to know when the blob has finished moving, and move onto the next instruction (can you use Promises to achieve this?)
- Add `turnLeft()` and `turnRight()` functions that change the rotation of the element (`rotate`) and again make it smooth via transitions.
- Add won and lost states that check whether a character hits the end square or a wall.

Once you've solved this, you'll move on to fully recreate the first exercise of the Bootcamp!
