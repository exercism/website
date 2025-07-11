const blob = {
  elem: document.querySelector('#blob'),
  top: 0,
  left: 0,
  direction: 'down',
}

function getCellAt(row, col) {
  const idx = row * 7 + col + 1
  return document.querySelector(`.cell:nth-child(${idx}`)
}

function cellIsEnterable(row, col) {
  const cell = getCellAt(row, col)
  return ['space', 'start', 'target'].some((cls) =>
    cell.classList.contains(cls)
  )
}

function move() {
  return new Promise((resolve, reject) => {
    blob.elem.addEventListener('transitionend', resolve, { once: true })
    if (blob.direction == 'down') {
      blob.top += 1
    } else if (blob.direction == 'up') {
      blob.top -= 1
    } else if (blob.direction == 'right') {
      blob.left += 1
    } else if (blob.direction == 'left') {
      blob.left -= 1
    }

    if (!cellIsEnterable(blob.top, blob.left)) {
      reject()
      //return
    }

    blob.elem.style.setProperty('--cell-x', blob.left)
    blob.elem.style.setProperty('--cell-y', blob.top)
  })
}
function turnLeft() {
  return new Promise((resolve, reject) => {
    blob.elem.addEventListener('transitionend', resolve, { once: true })
    const currentRotation = parseInt(
      getComputedStyle(blob.elem).getPropertyValue('--rotation')
    )
    if (blob.direction == 'down') {
      blob.direction = 'right'
    } else if (blob.direction == 'right') {
      blob.direction = 'up'
    }
    blob.elem.style.setProperty('--rotation', `${currentRotation - 90}deg`)
  })
}
function turnRight() {
  return new Promise((resolve, reject) => {
    blob.elem.addEventListener('transitionend', resolve, { once: true })
    const currentRotation = parseInt(
      getComputedStyle(blob.elem).getPropertyValue('--rotation')
    )
    if (blob.direction == 'up') {
      blob.direction = 'right'
    } else if (blob.direction == 'left') {
      blob.direction = 'up'
    } else if (blob.direction == 'right') {
      blob.direction = 'down'
    } else if (blob.direction == 'down') {
      blob.direction = 'left'
    }
    blob.elem.style.setProperty('--rotation', `${currentRotation + 90}deg`)
  })
}
/*const instructions = [
  moveDown,
  moveDown,
  moveDown,
  moveDown,
]
for (const instruction of instructions) {
  await instruction()
}*/

move()
  .then(turnLeft)
  .then(move)
  .then(move)
  .then(turnLeft)
  .then(move)
  .then(move)
  .then(turnRight)
  .then(move)
  .then(move)
  .then(turnRight)
  .then(move)
  .then(move)
  .then(move)
  .then(move)
  .then(move)
  .then(move)
  .then(turnLeft)
  .then(move)
  .then(move)
  .catch(() => {
    document.querySelector('#game-over').style.display = 'grid'
  })
