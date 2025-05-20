// Write any code that you want to run once, or any helper functions here.

function gameLoop() {
  // Write any code you want to happen on every animation frame here
  
  // Remember to setup the next animation frame before you finish
  requestAnimationFrame(gameLoop);
}

// This should probably be the final line in your
// program and the one that sets off the gameLoop.
requestAnimationFrame(gameLoop);