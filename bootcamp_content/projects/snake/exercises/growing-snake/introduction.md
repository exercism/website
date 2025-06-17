# Controlled Snake

In this exercise, we're expanding our snake game to add food that the snake can collect!

A white dot will appear on the screen. When the snake eats the dot, it should grow one segment longer. The dot should disappear and a new one should appear somewhere else randomly in the game.

### The `createElement` method

To solve this, you will need to use the [`createElement`](https://developer.mozilla.org/en-US/docs/Web/API/Document/createElement) method.

You can use it to create a new element, and add it to an existing element like this:

```js
// Create a new div element
const segment = document.createElement("div");

// Add a class
segment.classList.add("segment")

// Get an existing element
const snake = document.querySelector("#snake")

// Add the newly created segment to the snake
snake.appendChild(segment)
```

## Instructions

Add the respawning white dot and the snake growth functionality. Play with the example to get a feel for how it should work. You might like to use [`Math.random()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math/random) to help you randomly decide where the dot should appear each time.
