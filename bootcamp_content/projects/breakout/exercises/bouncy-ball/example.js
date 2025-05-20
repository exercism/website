const ball = {
  speed: 0.5,
  size: 4,
  left: 50,
  top: 96,
}
ball.velocityX = -1 * ball.speed
ball.velocityY = -1 * ball.speed

function updateBallCoordinates() {
  ball.left += ball.velocityX
  ball.top += ball.velocityY

  if (ball.left < 0) {
    ball.velocityX = 1 * ball.speed
  }
  if (ball.left > 100 - ball.size) {
    ball.velocityX = -1 * ball.speed
  }
  if (ball.top < 0) {
    ball.velocityY = 1 * ball.speed
  }
  if (ball.top > 100 - ball.size) {
    ball.velocityY = -1 * ball.speed
  }
  return true
}
function render() {
  document.querySelector('#ball').style.left = `${ball.left}%`
  document.querySelector('#ball').style.top = `${ball.top}%`
}
let lastTime = 0

function gameLoop() {
  const couldContinue = updateBallCoordinates() // game state logic
  render() // drawing logic

  if (couldContinue) {
    requestAnimationFrame(gameLoop)
  }
}

requestAnimationFrame(gameLoop)
