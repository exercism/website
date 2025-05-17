const ballSpeed = 0.5
let ballLeft = 50
let ballTop = 95
let ballVelocityX = -1 * ballSpeed
let ballVelocityY = -1 * ballSpeed

function updateBallCoordinates() {
  ballLeft += ballVelocityX
  ballTop += ballVelocityY

  if (ballLeft < 2.5) {
    return false
    ballVelocityX = 1 * ballSpeed
  }
  if (ballLeft > 97.5) {
    ballVelocityX = -1 * ballSpeed
  }
  if (ballTop < 2.5) {
    ballVelocityY = 1 * ballSpeed
  }
  if (ballTop > 97.5) {
    ballVelocityY = -1 * ballSpeed
  }
  return true
}
function render() {
  document.querySelector('#ball').style.left = `${ballLeft}%`
  document.querySelector('#ball').style.top = `${ballTop}%`
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
