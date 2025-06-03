const snake = {
  direction: 'left',
  length: 8,
  segments: [],
}

const game = {
  gridSize: 20,
  elem: document.querySelector('#game'),
}

const segments = Array.from(document.querySelectorAll('.snake-segment'))
for (let i = 0; i < snake.length; i++) {
  snake.segments.push({
    top: 10,
    left: 10 + i,
    elem: segments[i],
  })
}

window.addEventListener('keydown', (e) => {
  log(e.key)
  const head = snake.segments[0]
  if (e.key == 'ArrowRight') {
    snake.direction = 'right'
  } else if (e.key == 'ArrowUp') {
    snake.direction = 'up'
  } else if (e.key == 'ArrowLeft') {
    snake.direction = 'left'
  } else if (e.key == 'ArrowDown') {
    snake.direction = 'down'
  }
})

function moveSnake() {
  moveTail()
  moveHead()
}

function newHeadPosition() {
  const head = snake.segments[0]
  if (snake.direction == 'left') {
    return [head.left - 1, head.top]
  }
  if (snake.direction == 'right') {
    return [head.left + 1, head.top]
  }
  if (snake.direction == 'down') {
    return [head.left, head.top + 1]
  }
  if (snake.direction == 'up') {
    return [head.left, head.top - 1]
  }
}

function snakeWillEatTail() {
  const head = snake.segments[0]
  const [left, top] = newHeadPosition()
  for (const segment of snake.segments) {
    if (segment.left == left && segment.top == top) {
      return true
    }
  }
  return false
}

function moveHead() {
  const head = snake.segments[0]
  const [left, top] = newHeadPosition()
  head.left = left
  head.top = top
}

function moveTail() {
  for (let i = snake.length - 1; i > 0; i--) {
    const thisSegment = snake.segments[i]
    const aheadSegment = snake.segments[i - 1]
    thisSegment.left = aheadSegment.left
    thisSegment.top = aheadSegment.top
  }
}

function renderSnake() {
  snake.segments.forEach((segment) => {
    segment.elem.style.gridColumn = segment.left
    segment.elem.style.gridRow = segment.top
  })
}

function snakeHitEdge() {
  const head = snake.segments[0]
  return (
    head.left <= 0 ||
    head.left > game.gridSize ||
    head.top <= 0 ||
    head.top > game.gridSize
  )
}

function renderGameOver() {
  game.elem.style.backgroundColor = 'darkred'
}

let loopsRuns = 0
function gameLoop() {
  if (loopsRuns % 20 == 0) {
    if (snakeWillEatTail()) {
      renderGameOver()
      return
    }
    if (snakeHitEdge()) {
      renderGameOver()
      return
    }
    moveSnake()
    renderSnake()
  }
  loopsRuns++

  requestAnimationFrame(gameLoop)
}

renderSnake()
requestAnimationFrame(gameLoop)
