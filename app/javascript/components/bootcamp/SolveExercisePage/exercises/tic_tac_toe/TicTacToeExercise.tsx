import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'
import { addOrdinalSuffix } from '@/interpreter/describers/helpers'
import DrawExercise from '../draw/DrawExercise'
import { Color } from '../draw/shapes'

type GameStatus = 'running' | 'won' | 'draw' | 'error'

export default class TicTacToeExercise extends DrawExercise {
  private gameStatus: GameStatus = 'running'
  protected strokeColor: Color = { type: 'hex', color: '#333' }
  protected strokeWidth = 1
  protected fillColor: Color = { type: 'hex', color: '#ffffff' }
  protected gameWinner: null | 'x' | 'o' = null

  public constructor() {
    super('tic-tac-toe')

    /*this.boardElem = document.createElement('div')
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
    this.view.appendChild(this.boardElem)*/
  }

  public getState() {
    //console.log(this.shapes)
    return { gameStatus: this.gameStatus, gameWinner: this.gameWinner }
  }

  /*public placeX(executionCtx: ExecutionContext, row: number, col: number) {
    this.guardDoublePlacement(executionCtx, row, col)

    this.board[row - 1][col - 1] = 'X'
    this.fillCell(executionCtx, row, col, 'x')
  }

  public placeO(executionCtx: ExecutionContext, row: number, col: number) {
    this.guardDoublePlacement(executionCtx, row, col)

    this.board[row - 1][col - 1] = 'O'
    this.fillCell(executionCtx, row, col, 'o')
  }*/

  public errorInvalidMove(executionCtx: ExecutionContext) {
    this.gameStatus = 'error'
  }

  public announceWinner(executionCtx: ExecutionContext, winner: 'x' | 'o') {
    if (this.gameStatus !== 'running') {
      this.logicError('The game has already ended.')
    }
    if (winner !== 'x' && winner !== 'o') {
      this.logicError('You announce an invalid winner.')
    }
    this.gameWinner = winner
    this.gameStatus = 'won'
  }

  public announceDraw(executionCtx: ExecutionContext) {
    if (this.gameStatus !== 'running') {
      this.logicError('The game has already ended')
    }

    this.gameStatus = 'draw'
  }

  /*private guardDoublePlacement(
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
  }*/

  /*private fillCell(
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
  }*/

  public availableFunctions = [
    /*{
      name: 'place_x',
      func: this.placeX.bind(this),
      description: 'placed an X on the board',
    },
    {
      name: 'place_o',
      func: this.placeO.bind(this),
      description: 'placed an O on the board',
    },*/

    {
      name: 'stroke_color_hex',
      func: this.strokeColorHex.bind(this),
      description: 'set the stroke color to ${arg1}',
    },
    {
      name: 'stroke_width',
      func: this.setStrokeWidth.bind(this),
      description: 'set the stroke width to ${arg1}',
    },
    {
      name: 'line',
      func: this.line.bind(this),
      description: 'drew a line from (${arg1}, ${arg2}) to (${arg3}, ${arg4})',
    },
    {
      name: 'circle',
      func: this.circle.bind(this),
      description:
        'drew a circle with its center at (${arg1}, ${arg2}), and a radius of ${arg3}',
    },
    {
      name: 'rectangle',
      func: this.rectangle.bind(this),
      description:
        'drew a rectangle at coordinates (${arg1}, ${arg2}) with a width of ${arg3} and a height of ${arg4}',
    },
    {
      name: 'error_invalid_move',
      func: this.errorInvalidMove.bind(this),
      description:
        'alerted the user that they cannot place a piece in a cell that is already occupied',
    },
    {
      name: 'announce_winner',
      func: this.announceWinner.bind(this),
      description: 'announced the winner of the game as ${arg1}',
    },
    {
      name: 'announce_draw',
      func: this.announceDraw.bind(this),
      description: 'announced the game was a draw',
    },
  ]
}
