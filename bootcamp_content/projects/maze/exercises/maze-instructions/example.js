const cellsPerRow = 7
const blob = {
  elem: document.querySelector('#blob'),
  row: 0,
  col: 0,
  direction: 'down',
}

function getCellAt(row, col) {
  // We use +1 because nth-child is one-based but
  // our counting is zero-based.
  const idx = row * cellsPerRow + col + 1
  return document.querySelector(`.cell:nth-child(${idx})`)
}

function cellEnterable(row, col) {
  if (row < 0 || col < 0) {
    return false
  }
  if (row >= cellsPerRow || col >= cellsPerRow) {
    return false
  }

  const cell = getCellAt(row, col)
  return ['space', 'start', 'target'].some((cls) =>
    cell.classList.contains(cls)
  )
}

function move() {
  return new Promise((resolve, reject) => {
    if (blob.direction == 'down') {
      blob.row += 1
    } else if (blob.direction == 'up') {
      blob.row -= 1
    } else if (blob.direction == 'right') {
      blob.col += 1
    } else if (blob.direction == 'left') {
      blob.col -= 1
    }

    if (!cellEnterable(blob.row, blob.col)) {
      reject()
    }

    blob.elem.addEventListener('transitionend', resolve)
    blob.elem.style.setProperty('--cell-row', blob.row)
    blob.elem.style.setProperty('--cell-col', blob.col)
  })
}

function turnLeft() {
  return new Promise((resolve, reject) => {
    if (blob.direction == 'up') {
      blob.direction = 'left'
    } else if (blob.direction == 'down') {
      blob.direction = 'right'
    } else if (blob.direction == 'right') {
      blob.direction = 'up'
    } else if (blob.direction == 'left') {
      blob.direction = 'down'
    }

    const rotation =
      parseInt(getComputedStyle(blob.elem).getPropertyValue('--rotation')) - 90

    blob.elem.addEventListener('transitionend', resolve)
    blob.elem.style.setProperty('--rotation', `${rotation}deg`)
  })
}

function turnRight() {
  return new Promise((resolve, reject) => {
    if (blob.direction == 'up') {
      blob.direction = 'right'
    } else if (blob.direction == 'down') {
      blob.direction = 'left'
    } else if (blob.direction == 'right') {
      blob.direction = 'down'
    } else if (blob.direction == 'left') {
      blob.direction = 'up'
    }

    const rotation =
      parseInt(getComputedStyle(blob.elem).getPropertyValue('--rotation')) + 90

    blob.elem.addEventListener('transitionend', resolve)
    blob.elem.style.setProperty('--rotation', `${rotation}deg`)
  })
}

function showWinScreen() {
  document.querySelector('#won-screen').style.display = 'grid'
}
function showLostScreen() {
  document.querySelector('#lost-screen').style.display = 'grid'
}

function hideWinScreen() {
  document.querySelector('#won-screen').style.display = 'none'
}
function hideLostScreen() {
  document.querySelector('#lost-screen').style.display = 'none'
}

function checkForWin() {
  if (getCellAt(blob.row, blob.col).classList.contains('target')) {
    showWinScreen()
  } else {
    showLostScreen()
  }
}

document.querySelector('form').addEventListener('submit', (e) => {
  e.preventDefault()

  hideWinScreen()
  hideLostScreen()

  const lines = document.querySelector('textarea').value.split('\n')
  const instructions = lines.map((line) => {
    if (line == 'move()') return move
    if (line == 'turn_left()') return turnLeft
    if (line == 'turn_right()') return turnRight
  })
  const promise = instructions.reduce((promise, instruction) => {
    return promise.then(() => instruction())
  }, Promise.resolve())

  promise.then(checkForWin).catch(() => {
    showLostScreen()
  })
})
