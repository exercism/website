let turn = 'o'
let gameOver = false
const squares = Array.from(document.querySelectorAll('.square')).map((elem) => {
  // And add an event listener
  elem.addEventListener('pointerdown', handlePlacement)

  // Create our data
  return {
    elem: elem,
    content: null,
    name: 'foo',
  }
})

function checkPermutationForWin(permutation) {
  return permutation.every((idx) => squares[idx].content == turn)
}

function checkForWin() {
  const winningPermutation = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ].find((perm) => checkPermutationForWin(perm))

  if (winningPermutation) {
    gameOver = true
    for (const idx of winningPermutation) {
      squares[idx].elem.classList.add('win')
    }
  }
}

function checkForDraw() {
  if (squares.every((square) => square.content)) {
    gameOver = true
    for (const square of squares) {
      square.elem.classList.add('draw')
    }
  }
}

function toggleTurn() {
  turn = turn == 'o' ? 'x' : 'o'
}

function squareFromElem(elem) {
  return squares.find((s) => elem.isSameNode(s.elem))
}

function handlePlacement(event) {
  if (gameOver) return

  const square = squareFromElem(event.target)
  if (!square || square.content != null) {
    return
  }

  // Set the square
  square.content = turn
  square.elem.innerHTML = turn

  checkForWin()
  checkForDraw()
  toggleTurn()
}
