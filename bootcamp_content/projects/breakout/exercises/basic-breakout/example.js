const game = {
  left: 0,
  top: 0,
  right: 100,
  bottom: 100,
  elem: document.querySelector('#game'),
}

const ball = {
  velocityX: -0.5,
  velocityY: -0.5,
  diameter: 4,
  cx: 70,
  cy: 94,
  elem: document.querySelector('#ball'),
  left: () => ball.cx - ball.radius,
  right: () => ball.cx + ball.radius,
  bottom: () => ball.cy + ball.radius,
}
ball.radius = ball.diameter / 2

const paddle = {
  elem: document.querySelector('#paddle'),
  cx: 70,
  top: 96,
  width: 20,
  left: () => paddle.cx - paddle.width / 2,
  right: () => paddle.cx + paddle.width / 2,
}

const blocks = []
for (const elem of document.querySelectorAll('.block')) {
  blocks.push({
    elem: elem,
    smashed: false,
  })
}

function isGameLost() {
  return ball.bottom() >= 100
}
function isGameWon() {
  return blocks.every((block) => block.smashed)
}

function updateBall() {
  detectBallBlockCollisions()
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
  handleBallPaddleInteraction()
}

function handleBallPaddleInteraction() {
  if (!isBallTouchingPaddle()) {
    return
  }

  const distance = Math.abs(ball.cx - paddle.cx)
  const distancePercentage = distance / (paddle.width / 2)
  const speedYModifier = 0.5 + 1.5 * distancePercentage

  ball.velocityY = -Math.max(
    Math.min(2, Math.abs(ball.velocityY) * speedYModifier),
    0.5
  )

  const speedX = distancePercentage

  if (ball.velocityX > 0 && ball.cx < paddle.cx - 5) {
    ball.velocityX = -speedX
  } else if (ball.velocityX < 0 && ball.cx > paddle.cx + 5) {
    ball.velocityX = speedX
  } else if (ball.velocityX > 0) {
    ball.velocityX = speedX
  } else {
    ball.velocityX = -speedX
  }
}

function isBallTouchingPaddle() {
  return (
    ball.bottom() >= paddle.top &&
    ball.left() >= paddle.left() &&
    ball.right() <= paddle.right()
  )
}

function detectBallBlockCollisions() {
  for (const block of blocks) {
    if (block.smashed) {
      continue
    }

    const touching = ballBlockInteraction(block)
    if (!touching) {
      continue
    }

    block.smashed = true
    block.elem.style.opacity = 0

    const [horizontalTouching, verticalTouching] = touching

    if (horizontalTouching) {
      ball.velocityX *= -1
    }
    if (verticalTouching) {
      ball.velocityY *= -1
    }

    break
  }
}

function ballBlockInteraction(block) {
  ballRect = ball.elem.getBoundingClientRect()
  blockRect = block.elem.getBoundingClientRect()

  if (ballRect.right < blockRect.left || ballRect.left > blockRect.right) {
    return false
  }
  // If the ball is below the ball return false
  if (ballRect.top > blockRect.bottom) {
    return false
  }

  // If the ball is above the ball return false
  if (ballRect.bottom < blockRect.top) {
    return false
  }

  const margin = ballRect.width / 5

  let horizontalEdge = false
  let verticalEdge = false

  log(
    ballRect.right - blockRect.left,
    blockRect.right - ballRect.right,
    blockRect.bottom - ballRect.top,
    ballRect.bottom - blockRect.top
  )

  if (ballRect.right - blockRect.left < margin) {
    horizontalEdge = true
  }
  if (blockRect.right - ballRect.left < margin) {
    horizontalEdge = true
  }

  if (blockRect.bottom - ballRect.top < margin) {
    verticalEdge = true
  }
  if (ballRect.bottom - blockRect.top < margin) {
    verticalEdge = true
  }

  // Return horizontal/vertical boolean pair
  return [horizontalEdge, verticalEdge]
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

function renderGameWon() {
  game.elem.style.background = 'green'
  paddle.elem.style.opacity = 0.2
}

function renderGameLost() {
  game.elem.style.background = 'darkred'
  paddle.elem.style.opacity = 0.2
}

window.addEventListener('mousemove', (e) => {
  gameRect = game.elem.getBoundingClientRect()
  const leftPx = e.pageX - gameRect.left
  let leftPc = (leftPx / gameRect.width) * 100
  const min = paddle.width / 2
  const max = 100 - paddle.width / 2
  const boundaried = Math.min(max, Math.max(min, leftPc))
  paddle.cx = boundaried
})

function gameLoop() {
  // Updating
  updateBall()

  // Rendering
  renderBall()
  renderPaddle()

  if (isGameWon()) {
    renderGameWon()
    return
  }
  if (isGameLost()) {
    renderGameLost()
    return
  }

  requestAnimationFrame(gameLoop)
}
requestAnimationFrame(gameLoop)
