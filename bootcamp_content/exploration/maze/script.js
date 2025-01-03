const maze = document.getElementById('maze')

// Maze configuration: 0 = open, 1 = blocked
let mazeLayout
let characterPosition
let direction

function createMaze() {
  maze.innerHTML = ''
  maze.style.setProperty('--size', mazeLayout.length)

  for (let y = 0; y < mazeLayout.length; y++) {
    for (let x = 0; x < mazeLayout[y].length; x++) {
      const cell = document.createElement('div')
      cell.classList.add('cell')
      if (mazeLayout[y][x] === 1) {
        cell.classList.add('blocked')
      }
      if (x === characterPosition.x && y === characterPosition.y) {
        const character = document.createElement('div')
        character.classList.add('character')
        character.classList.add('direction-' + direction)
        cell.appendChild(character)
      }
      maze.appendChild(cell)
    }
  }
}

function moveCharacter(dx, dy) {
  const newX = characterPosition.x + dx
  const newY = characterPosition.y + dy
  if (
    newX >= 0 &&
    newX < mazeLayout[0].length &&
    newY >= 0 &&
    newY < mazeLayout.length &&
    mazeLayout[newY][newX] === 0
  ) {
    characterPosition.x = newX
    characterPosition.y = newY
    createMaze()
  }
}

document.addEventListener('keydown', (e) => {
  switch (e.key) {
    case 'ArrowUp':
      moveCharacter(0, -1)
      break
    case 'ArrowDown':
      moveCharacter(0, 1)
      break
    case 'ArrowLeft':
      moveCharacter(-1, 0)
      break
    case 'ArrowRight':
      moveCharacter(1, 0)
      break
  }
})
function move() {
  if (direction == 'up') {
    moveCharacter(0, -1)
  } else if (direction == 'down') {
    moveCharacter(0, 1)
  } else if (direction == 'right') {
    moveCharacter(1, 0)
  } else if (direction == 'left') {
    moveCharacter(-1, 0)
  }
}

function turn_left() {
  if (direction == 'up') {
    direction = 'left'
  } else if (direction == 'down') {
    direction = 'right'
  } else if (direction == 'right') {
    direction = 'up'
  } else if (direction == 'left') {
    direction = 'down'
  }
  createMaze()
}

function turn_right() {
  if (direction == 'up') {
    direction = 'right'
  } else if (direction == 'down') {
    direction = 'left'
  } else if (direction == 'right') {
    direction = 'down'
  } else if (direction == 'left') {
    direction = 'up'
  }
  createMaze()
}

instructions = [
  move,
  move,
  turn_left,
  move,
  move,
  turn_left,
  move,
  move,
  turn_right,
  move,
]
/*for (let i = 0; i < instructions.length; i++) {
  setTimeout(instructions[i], i * 100)
} */

function gameLoop() {
  const instruction = instructions.shift()
  if (!instruction) {
    return
  }
  instruction()
  setTimeout(gameLoop, 100)
}

function setupDefault() {
  mazeLayout = [
    [0, 1, 0, 0, 0, 1, 0, 0, 0, 0],
    [0, 1, 0, 1, 0, 1, 1, 1, 0, 1],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 1],
    [0, 1, 1, 1, 0, 1, 1, 1, 0, 1],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0, 1],
    [0, 0, 0, 0, 0, 0, 0, 1, 0, 0],
    [1, 1, 1, 1, 1, 1, 0, 1, 0, 0],
  ]

  characterPosition = { x: 0, y: 0 }
  direction = 'down'
}

function setupGrid(layout) {
  mazeLayout = layout
}
function setupDirection(dir) {
  direction = dir
}
function setupPosition(x, y) {
  characterPosition = { x: x, y: y }
}

// This is what we want to call for an exercise where we're testing
// the code runs as expected.
setupDefault()
createMaze()
gameLoop()

// setupGrid([[0,0,0],[0,0,0],[0,0,0]]);
// setupDirection("up")
// setupPosition(1,1)

// move()
console.log(characterPosition)
