const segmentSize = 5
const margin = 5
const max = 100 - margin - segmentSize
const min = margin

const snake = {
  direction: 'left',
  body: [],
  length: 5,
  elem: document.querySelector('#snake'),
}

// Initialize snake body
for (let i = 0; i < snake.length; i++) {
  snake.body.push({ top: 50, left: 50 + i * segmentSize })
}

// Movement logic
function updateDirection() {
  const head = snake.body[0]
  const { top, left, direction } = snake

  if (snake.direction === 'up' && head.top <= min) {
    snake.direction = 'left'
  } else if (snake.direction === 'left' && head.left <= min) {
    snake.direction = 'down'
  } else if (snake.direction === 'down' && head.top >= max) {
    snake.direction = 'right'
  } else if (snake.direction === 'right' && head.left >= max) {
    snake.direction = 'up'
  }
}

function moveSnake() {
  const head = { ...snake.body[0] }

  switch (snake.direction) {
    case 'up':
      head.top -= segmentSize
      break
    case 'down':
      head.top += segmentSize
      break
    case 'left':
      head.left -= segmentSize
      break
    case 'right':
      head.left += segmentSize
      break
  }

  // Add new head, remove tail
  snake.body.unshift(head)
  snake.body.pop()
}

function renderSnake() {
  //log(document.body.children)
  //log(game.children)
  for (let i = 0; i < snake.body.length; i++) {
    const seg = snake.elem.children[i]
    const { top, left } = snake.body[i]
    seg.style.top = `${top}%`
    seg.style.left = `${left}%`
    seg.style.width = `${segmentSize}%`
    seg.style.height = `${segmentSize}%`
  }
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

requestAnimationFrame(gameLoop)
