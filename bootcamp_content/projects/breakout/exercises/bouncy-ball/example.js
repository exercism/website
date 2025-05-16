const ballSpeed = 0.5
let ballLeft = 50
let ballTop = 95
let ballVelocityX = -1 * ballSpeed
let ballVelocityY = -1 * ballSpeed

function updateBallCoordinates() {
  ballLeft += ballVelocityX
  ballTop += ballVelocityY

  if (ballLeft < 0) {
    ballVelocityX = 1 * ballSpeed
  }
  if (ballLeft > 95) {
    ballVelocityX = -1 * ballSpeed
  }
  if (ballTop < 0) {
    ballVelocityY = 1 * ballSpeed
  }
  if (ballTop > 95) {
    ballVelocityY = -1 * ballSpeed
  }
}
function render() {
  document.querySelector('#ball').style.left = `${ballLeft}%`
  document.querySelector('#ball').style.top = `${ballTop}%`
}
let lastTime = 0

function gameLoop() {
  updateBallCoordinates() // game state logic
  render() // drawing logic

  requestAnimationFrame(gameLoop)
}

requestAnimationFrame(gameLoop)
