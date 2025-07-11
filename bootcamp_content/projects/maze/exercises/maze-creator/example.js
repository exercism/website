const layout = [
  [2, 1, 0, 0, 0, 1, 0],
  [0, 1, 0, 1, 0, 1, 1],
  [0, 0, 0, 1, 0, 0, 0],
  [0, 1, 1, 1, 0, 1, 1],
  [0, 0, 1, 0, 0, 1, 0],
  [1, 1, 1, 1, 0, 1, 1],
  [0, 0, 0, 0, 0, 0, 3],
]

mazeElem = document.getElementById('maze')
for (const row of layout) {
  for (const cell of row) {
    const cellElem = document.createElement('div')
    cellElem.classList.add('cell')
    if (cell == 0) {
      cellElem.classList.add('space')
    } else if (cell == 1) {
      cellElem.classList.add('wall')
    } else if (cell == 2) {
      cellElem.classList.add('start')
    } else if (cell == 3) {
      cellElem.classList.add('goal')
    }
    console.log('HERE')
    mazeElem.appendChild(cellElem)
  }
}
const startCell = document.querySelector('.cell.start')
const blobElem = document.createElement('div')
blobElem.id = 'blob'
startCell.appendChild(blobElem)
