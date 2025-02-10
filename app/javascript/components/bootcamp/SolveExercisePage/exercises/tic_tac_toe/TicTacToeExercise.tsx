import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'
import { addOrdinalSuffix } from '@/interpreter/describers/helpers'

type GameStatus = 'running' | 'error'

export default class TicTacToeExercise extends Exercise {
  private gameStatus: GameStatus = 'running'
  private board = [
    ['', '', ''],
    ['', '', ''],
    ['', '', ''],
  ]

  public constructor() {
    super('tic-tac-toe')

    this.boardElem = document.createElement('div')
    this.boardElem.classList.add('board')
    ;[1, 2, 3].forEach((row) => {
      ;[1, 2, 3].forEach((col) => {
        const cell = document.createElement('div')
        cell.classList.add('cell', `cell-${row}-${col}`)
        this.boardElem.appendChild(cell)

        const x = document.createElement('div')
        x.classList.add('x')
        cell.appendChild(x)

        const o = document.createElement('div')
        o.classList.add('o')
        cell.appendChild(o)
      })
    })
    this.view.appendChild(this.boardElem)
  }

  public getState() {
    return { gameStatus: this.gameStatus }
  }

  public placeX(executionCtx: ExecutionContext, row: number, col: number) {
    this.guardDoublePlacement(executionCtx, row, col)

    this.board[row - 1][col - 1] = 'X'
    this.fillCell(executionCtx, row, col, 'x')
  }

  public placeO(executionCtx: ExecutionContext, row: number, col: number) {
    this.guardDoublePlacement(executionCtx, row, col)

    this.board[row - 1][col - 1] = 'O'
    this.fillCell(executionCtx, row, col, 'o')
  }

  public error_invalid_placement(executionCtx: ExecutionContext) {
    this.gameStatus = 'error'
  }

  private guardDoublePlacement(
    executionCtx: ExecutionContext,
    row: number,
    col: number
  ) {
    if (this.board[row - 1][col - 1] !== '') {
      executionCtx.logicError(
        `Oh no! There is already a piece in the ${addOrdinalSuffix(
          col
        )} cell on the ${addOrdinalSuffix(row)} row.`
      )
    }
  }

  private fillCell(
    executionCtx: ExecutionContext,
    row: number,
    col: number,
    ox: 'x' | 'o'
  ) {
    this.addAnimation({
      targets: `#${this.view.id} .board .cell-${row}-${col} .${ox}`,
      duration: 1,
      transformations: {
        opacity: 1,
      },
      offset: executionCtx.getCurrentTime(),
    })
  }

  public availableFunctions = [
    {
      name: 'place_x',
      func: this.placeX.bind(this),
      description: 'placed an X on the board',
    },
    {
      name: 'place_o',
      func: this.placeO.bind(this),
      description: 'placed an O on the board',
    },
    {
      name: 'error_invalid_placement',
      func: this.placeO.bind(this),
      description:
        'alerted the user that they cannot place a piece in a cell that is already occupied',
    },
  ]
}
