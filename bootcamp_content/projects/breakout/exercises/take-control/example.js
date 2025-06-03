const game = {
  left: 0,
  top: 0,
  right: 100,
  bottom: 100,
  elem: document.querySelector('#game'),
}

const ball = {
  speed: 0.5,
  diameter: 4,
  cx: 50,
  cy: 94,
  elem: document.querySelector('#ball'),
  left: () => ball.cx - ball.radius,
  right: () => ball.cx + ball.radius,
  bottom: () => ball.cy + ball.radius,
}
ball.radius = ball.diameter / 2
ball.velocityX = -1 * ball.speed
ball.velocityY = -1 * ball.speed

const paddle = {
  elem: document.querySelector('#paddle'),
  cx: 50,
  top: 96,
  width: 20,
  left: () => paddle.cx - paddle.width / 2,
  right: () => paddle.cx + paddle.width / 2,
}

function isGameOver() {
  return ball.bottom() >= 100
}

function updateBall() {
  updateBallPosition()
  updateBallDirection()
}

function updateBallDirection() {
  if (ball.cx - ball.radius <= game.left) {
    ball.velocityX *= -1
  }
  if (ball.cx + ball.radius >= game.right) {
    ball.velocityX *= -1
  }
  if (ball.cy - ball.radius <= game.top) {
    ball.velocityY *= -1
  }
  if (isBallTouchingPaddle()) {
    ball.velocityY = -1 * ball.speed
  }
}

function isBallTouchingPaddle() {
  return (
    ball.bottom() >= paddle.top &&
    ball.left() >= paddle.left() &&
    ball.right() <= paddle.right()
  )
}

function updateBallPosition() {
  ball.cx += ball.velocityX
  ball.cy += ball.velocityY
}

function renderBall() {
  ball.elem.style.left = `${ball.cx}%`
  ball.elem.style.top = `${ball.cy}%`
}

function renderPaddle() {
  paddle.elem.style.left = `${paddle.cx}%`
}

function renderGameOver() {
  game.elem.style.background = 'darkred'
  paddle.elem.style.opacity = 0.2
}

window.addEventListener('mousemove', (e) => {
  gameRect = game.elem.getBoundingClientRect()
  const leftPx = e.pageX - gameRect.left
  let leftPc = (leftPx / gameRect.width) * 100
  const min = paddle.width / 2
  const max = 100 - paddle.width / 2
  const boundried = Math.min(max, Math.max(min, leftPc))
  paddle.cx = boundried
})

function gameLoop() {
  updateBall()
  renderBall()
  renderPaddle()

  if (isGameOver()) {
    renderGameOver()
    return
  }

  requestAnimationFrame(gameLoop)
}
requestAnimationFrame(gameLoop)
