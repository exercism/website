const snake = {
  direction: 'left',
  length: 5,
  segmentSize: 5,
  elem: document.querySelector('#snake'),
  segments: [],
}

const game = { margin: 5 }
game.leftEdge = game.margin
game.topEdge = game.margin
game.rightEdge = 100 - snake.segmentSize - game.margin
game.bottomEdge = 100 - snake.segmentSize - game.margin

for (let i = 0; i < snake.length; i++) {
  snake.segments.push({
    top: 50,
    left: 50 + i * snake.segmentSize,
    elem: snake.elem.children[i],
  })
}

function updateDirection() {
  const head = snake.segments[0]
  if (snake.direction == 'down' && head.top >= game.bottomEdge) {
    snake.direction = 'right'
  } else if (snake.direction == 'right' && head.left >= game.rightEdge) {
    snake.direction = 'up'
  } else if (snake.direction == 'up' && head.top <= game.topEdge) {
    snake.direction = 'left'
  } else if (snake.direction == 'left' && head.left <= game.leftEdge) {
    snake.direction = 'down'
  }
}

function moveSnake() {
  moveTail()
  moveHead()
}

function moveHead() {
  if (snake.direction == 'left') {
    snake.segments[0].left = snake.segments[0].left - snake.segmentSize
  }
  if (snake.direction == 'right') {
    snake.segments[0].left = snake.segments[0].left + snake.segmentSize
  }
  if (snake.direction == 'down') {
    snake.segments[0].top = snake.segments[0].top + snake.segmentSize
  }
  if (snake.direction == 'up') {
    snake.segments[0].top = snake.segments[0].top - snake.segmentSize
  }
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
    segment.elem.style.left = `${segment.left}%`
    segment.elem.style.top = `${segment.top}%`
  })
}

let loopsRuns = 0
function gameLoop() {
  if (loopsRuns % 10 == 0) {
    updateDirection()
    moveSnake()
    renderSnake()
  }
  loopsRuns++

  requestAnimationFrame(gameLoop)
}

renderSnake()
requestAnimationFrame(gameLoop)
