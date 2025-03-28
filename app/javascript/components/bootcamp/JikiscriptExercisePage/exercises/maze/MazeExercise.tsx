import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import cloneDeep from 'lodash.clonedeep'
import { isString } from '@/interpreter/checks'
import { randomEmoji } from '../../test-runner/generateAndRunTestSuite/genericSetupFunctions'
import { isEqual } from 'lodash'
import * as Jiki from '@/interpreter/jikiObjects'
import { exec } from 'child_process'
import { buildSquare, type SquareInstance } from './Square'
import { UserDefinedMethod } from '@/interpreter/functions'

type Cell = 0 | 1 | 2 | 3 | 4 | 5 | 6 | string

export default class MazeExercise extends Exercise {
  private Square = buildSquare(this)

  private mazeLayout: SquareInstance[][] = []
  private gridSize: number = 0
  protected characterPosition: { x: number; y: number } = { x: 0, y: 0 }
  private direction: string = 'down'
  private angle: number = 180
  private duration: number = 200
  private characterSelector: string
  private squareSize: number = 0
  private character: HTMLElement
  private cells: HTMLElement

  private startingAngles = { down: 180, up: 0, left: -90, right: 90 }

  public getState() {
    return {
      direction: this.direction,
      position: [this.characterPosition.x, this.characterPosition.y],
      collectedEmojis: this.collectedEmojis,
    }
  }

  public getGameResult() {
    return 'win'
  }

  public randomEmojisAllCollected() {
    // Turn array of emoji strings into a count map
    const expected = this.randomEmojis.reduce((acc, emoji) => {
      acc[emoji] = (acc[emoji] || 0) + 1
      return acc
    }, {})
    return isEqual(this.collectedEmojis, expected)
  }

  public constructor() {
    super('maze')

    this.container = document.createElement('div')
    this.view.appendChild(this.container)

    this.cells = document.createElement('div')
    this.cells.classList.add('cells')
    this.container.appendChild(this.cells)

    this.character = document.createElement('div')
    this.character.classList.add('character')
    this.container.appendChild(this.character)
    this.characterSelector = `#${this.view.id} .character`
    this.redrawMaze()

    this.emojiMode = false
    this.oopMode = false
    this.randomEmojis = []
  }

  // Setup Functions
  public setupGrid(executionCtx: ExecutionContext, layout: Cell[][]) {
    layout = this.populateRandomEmojis(layout)
    this.mazeLayout = this.cellsToSquares(executionCtx, layout)
    this.initialMazeLayout = this.cellsToSquares(executionCtx, layout)

    this.gridSize = layout.length
    this.squareSize = 100 / layout.length
    this.redrawMaze()
  }
  private populateRandomEmojis(layout: Cell[][]): Cell[][] {
    const reservedEmojis = ['⬜', '🧱', '⭐', '🏁', '🔥', '💩']
    return layout.map((row) =>
      row.map((cell) => {
        if (cell != 6) {
          return cell
        }

        let emoji: string | undefined
        do {
          emoji = randomEmoji()
          if (reservedEmojis.includes(emoji!)) {
            emoji = undefined
          }
        } while (emoji === undefined)

        this.randomEmojis.push(emoji)
        return emoji
      })
    )
  }
  private cellsToSquares(
    executionCtx: ExecutionContext,
    layout: Cell[][]
  ): SquareInstance[][] {
    return layout.map((row, ridx) =>
      row.map((cell, cidx) => {
        if (cell === 0) {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.False,
            Jiki.False,
            Jiki.False,
            new Jiki.String(''),
          ])
        } else if (cell === 1) {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.False,
            Jiki.False,
            Jiki.True,
            new Jiki.String(''),
          ])
        } else if (cell === 2) {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.True,
            Jiki.False,
            Jiki.False,
            new Jiki.String(''),
          ])
        } else if (cell === 3) {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.False,
            Jiki.True,
            Jiki.False,
            new Jiki.String(''),
          ])
        } else if (cell === 4) {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.False,
            Jiki.False,
            Jiki.False,
            new Jiki.String('🔥'),
          ])
        } else if (cell === 5) {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.False,
            Jiki.False,
            Jiki.False,
            new Jiki.String('💩'),
          ])
        } else {
          return this.Square.instantiate(executionCtx, [
            new Jiki.Number(ridx),
            new Jiki.Number(cidx),
            Jiki.True,
            Jiki.False,
            Jiki.False,
            Jiki.False,
            new Jiki.String(cell.toString()),
          ])
        }
      })
    ) as SquareInstance[][]
  }

  public enableEmojiMode(_: ExecutionContext) {
    this.emojiMode = true
  }
  public enableOOP(_: ExecutionContext) {
    this.oopMode = true
  }

  private redrawMaze(): void {
    this.cells.innerHTML = ''
    this.view.style.setProperty('--gridSize', this.gridSize.toString())

    for (let y = 0; y < this.mazeLayout.length; y++) {
      for (let x = 0; x < this.mazeLayout[y].length; x++) {
        const square = this.mazeLayout[y][x]
        const contents = square.getUnwrappedField('contents')

        const cell = document.createElement('div')
        cell.classList.add('cell', `cell-${y}-${x}`)
        if (square.getUnwrappedField('is_start')) cell.classList.add('start')
        if (square.getUnwrappedField('is_finish')) cell.classList.add('target')
        if (square.getUnwrappedField('is_wall')) cell.classList.add('blocked')
        if (contents == '🔥') cell.classList.add('fire')
        if (contents == '💩') cell.classList.add('poop')

        const child = document.createElement('div')
        child.classList.add('emoji')
        child.textContent = contents.toString()
        cell.appendChild(child)
        this.cells.appendChild(cell)
      }
    }
  }

  public moveCharacter(executionCtx: ExecutionContext, dx: number, dy: number) {
    const newX = this.characterPosition.x + dx
    const newY = this.characterPosition.y + dy

    this.characterPosition.x = newX
    this.characterPosition.y = newY

    this.animateMove(executionCtx)
  }

  private animateMove(executionCtx: ExecutionContext) {
    const yRow = this.mazeLayout[this.characterPosition.y]
    if (!yRow) {
      executionCtx.logicError('Oh no, you tried to move off the map.')
      executionCtx.updateState('gameOver', true)
      return
    }

    const square = yRow[this.characterPosition.x]

    // If we can't move, blow up
    if (square === undefined) {
      executionCtx.logicError('Oh no, you tried to move off the map')
      executionCtx.updateState('gameOver', true)
      return
    }

    // If we've hit a bad square, still animate but also animate color
    if (square.getUnwrappedField('is_wall')) {
      executionCtx.logicError('Ouch! You walked into a wall!')
      executionCtx.updateState('gameOver', true)
      return
    }

    // If you hit an invalid square, blow up.
    else if (square.getUnwrappedField('contents') === '🔥') {
      executionCtx.logicError('Ouch! You walked into the fire!')
      executionCtx.updateState('gameOver', true)
      return
    }

    // If you hit an invalid square, blow up.
    else if (square.getUnwrappedField('contents') === '💩') {
      executionCtx.logicError('Ewww! You walked into the poop! 💩💩💩')
      executionCtx.updateState('gameOver', true)
      return
    } else if (square.getUnwrappedField('is_finish')) {
      this.gameOverWin(executionCtx)
    }

    this.addAnimation({
      targets: this.characterSelector,
      duration: this.duration,
      transformations: {
        left: `${this.characterPosition.x * this.squareSize}%`,
        top: `${this.characterPosition.y * this.squareSize}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(this.duration)
  }

  private removeEmoji(executionCtx: ExecutionContext) {
    const yRow = this.mazeLayout[this.characterPosition.y]
    const square = yRow[this.characterPosition.x]
    const fn = square.getMethod('remove_emoji')!.fn as Jiki.RawMethod
    fn.call(undefined, executionCtx, square)
  }

  private gameOverWin(executionCtx: ExecutionContext) {
    executionCtx.updateState('gameOver', true)

    this.addAnimation({
      targets: this.characterSelector,
      duration: 200,
      transformations: {
        backgroundColor: `#0f0`,
      },
      offset: executionCtx.getCurrentTime(),
    })
  }

  private animateRotate(executionCtx: ExecutionContext) {
    this.addAnimation({
      targets: this.characterSelector,
      duration: this.duration,
      transformations: {
        rotate: this.angle,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(this.duration)
  }

  public move(executionCtx: ExecutionContext) {
    switch (this.direction) {
      case 'up':
        this.moveCharacter(executionCtx, 0, -1)
        break
      case 'down':
        this.moveCharacter(executionCtx, 0, 1)
        break
      case 'right':
        this.moveCharacter(executionCtx, 1, 0)
        break
      case 'left':
        this.moveCharacter(executionCtx, -1, 0)
        break
      default:
        console.log(`Unknown direction: ${this.direction}`)
    }
  }

  public turnLeft(executionCtx: ExecutionContext) {
    this.angle -= 90

    if (this.direction == 'up') {
      this.direction = 'left'
    } else if (this.direction == 'down') {
      this.direction = 'right'
    } else if (this.direction == 'right') {
      this.direction = 'up'
    } else if (this.direction == 'left') {
      this.direction = 'down'
    }
    this.animateRotate(executionCtx)
  }

  public turnRight(executionCtx: ExecutionContext) {
    this.angle += 90

    if (this.direction == 'up') {
      this.direction = 'right'
    } else if (this.direction == 'down') {
      this.direction = 'left'
    } else if (this.direction == 'right') {
      this.direction = 'down'
    } else if (this.direction == 'left') {
      this.direction = 'up'
    }
    this.animateRotate(executionCtx)
  }

  private describeSquare(
    executionCtx: ExecutionContext,
    square: SquareInstance | undefined
  ): SquareInstance | Jiki.String {
    if (!square) {
      if (this.oopMode) {
        return this.Square.instantiate(executionCtx, [
          new Jiki.Number(0),
          new Jiki.Number(0),
          Jiki.False,
          Jiki.False,
          Jiki.False,
          Jiki.False,
          new Jiki.String(''),
        ]) as SquareInstance
      }
      return new Jiki.String(this.emojiMode ? '🧱' : 'wall')
    }

    if (this.oopMode) {
      return square
    }

    let value: string
    if (square.getUnwrappedField('is_wall')) {
      value = this.emojiMode ? '🧱' : 'wall'
    } else if (square.getUnwrappedField('is_finish')) {
      value = this.emojiMode ? '🏁' : 'target'
    } else if (square.getUnwrappedField('is_start')) {
      value = this.emojiMode ? '⭐' : 'start'
    } else if (square.getUnwrappedField('contents') === '🔥') {
      value = this.emojiMode ? '🔥' : 'fire'
    } else if (square.getUnwrappedField('contents') === '💩') {
      value = this.emojiMode ? '💩' : 'poop'
    } else {
      if (this.emojiMode) {
        const contents = square.getUnwrappedField('contents')
        value = contents == '' ? '⬜' : contents
      } else {
        value = 'empty'
      }
    }
    return new Jiki.String(value)
  }

  public canMoveToSquare(square: SquareInstance | undefined): Jiki.Boolean {
    if (!square) {
      return Jiki.False
    }
    const contents = square.getUnwrappedField('contents')
    if (
      square.getUnwrappedField('is_wall') ||
      contents === '🔥' ||
      contents === '💩'
    ) {
      return Jiki.False
    }
    return Jiki.True
  }

  public canTurnLeft(_: ExecutionContext): Jiki.Boolean {
    return this.canMoveToSquare(this.lookLeft())
  }
  public canTurnRight(_: ExecutionContext): Jiki.Boolean {
    return this.canMoveToSquare(this.lookRight())
  }
  public canMove(_: ExecutionContext): Jiki.Boolean {
    return this.canMoveToSquare(this.lookAhead())
  }

  public lookLeft(): SquareInstance | undefined {
    let { x, y } = this.characterPosition

    if (this.direction === 'up') {
      x -= 1
    } else if (this.direction === 'down') {
      x += 1
    } else if (this.direction === 'left') {
      y += 1
    } else if (this.direction === 'right') {
      y -= 1
    }
    if (x >= 0 && x < this.gridSize && y >= 0 && y < this.gridSize) {
      return this.mazeLayout[y][x]
    }
  }

  public lookRight(): SquareInstance | undefined {
    let { x, y } = this.characterPosition

    if (this.direction === 'up') {
      x += 1
    } else if (this.direction === 'down') {
      x -= 1
    } else if (this.direction === 'left') {
      y -= 1
    } else if (this.direction === 'right') {
      y += 1
    }
    if (x >= 0 && x < this.gridSize && y >= 0 && y < this.gridSize) {
      return this.mazeLayout[y][x]
    }
  }

  private lookAhead(): SquareInstance | undefined {
    let { x, y } = this.characterPosition

    if (this.direction === 'up') {
      y -= 1
    } else if (this.direction === 'down') {
      y += 1
    } else if (this.direction === 'left') {
      x -= 1
    } else if (this.direction === 'right') {
      x += 1
    }
    if (x >= 0 && x < this.gridSize && y >= 0 && y < this.gridSize) {
      return this.mazeLayout[y][x]
    }
  }

  private look(
    executionCtx: ExecutionContext,
    direction: Jiki.String
  ): SquareInstance | Jiki.String {
    if (direction.value === 'down') {
      return this.describeSquare(
        executionCtx,
        this.mazeLayout[this.characterPosition.y] &&
          this.mazeLayout[this.characterPosition.y][this.characterPosition.x]
      )
    }

    let square: SquareInstance | undefined
    if (direction.value === 'left') {
      square = this.lookLeft()
    } else if (direction.value === 'right') {
      square = this.lookRight()
    } else if (direction.value === 'ahead') {
      square = this.lookAhead()
    } else {
      return executionCtx.logicError(
        `You asked the blob to look in a direction it doesn't know about. It can only look \"left\", \"right\", or \"ahead\". You asked it to look \"${direction}\".`
      )
    }
    return this.describeSquare(executionCtx, square)
  }

  public getInitialMaze(_: ExecutionContext): SquareInstance[][] {
    return Jiki.wrapJSToJikiObject(this.initialMazeLayout)
  }

  public setupDirection(_: ExecutionContext, direction: string) {
    this.direction = direction
    this.angle = this.startingAngles[direction]
    this.character.style.transform = `rotate(${this.angle}deg)`
  }
  public setupPosition(_: ExecutionContext, x: number, y: number) {
    this.characterPosition = { x: x, y: y }
    this.character.style.left = `${this.characterPosition.x * this.squareSize}%`
    this.character.style.top = `${this.characterPosition.y * this.squareSize}%`
  }
  public announceEmojis(_: ExecutionContext, emojis: Jiki.Dictionary) {
    this.collectedEmojis = Jiki.unwrapJikiObject(emojis)
  }

  public availableFunctions = [
    {
      name: 'move',
      func: this.move.bind(this),
      description: 'moved the character one step forward',
    },
    {
      name: 'turn_left',
      func: this.turnLeft.bind(this),
      description: 'turned the character to the left',
    },
    {
      name: 'turn_right',
      func: this.turnRight.bind(this),
      description: 'turned the character to the right',
    },
    {
      name: 'can_turn_left',
      func: this.canTurnLeft.bind(this),
      description: 'checked if the character can turn left',
    },
    {
      name: 'can_turn_right',
      func: this.canTurnRight.bind(this),
      description: 'checked if the character can turn right',
    },
    {
      name: 'can_move',
      func: this.canMove.bind(this),
      description: 'checked if the character can move forward',
    },
    {
      name: 'look',
      func: this.look.bind(this),
      description: 'looked in a direction and returns what is there',
    },
    {
      name: 'get_initial_maze',
      func: this.getInitialMaze.bind(this),
      description: 'get the initial maze layout',
    },
    {
      name: 'announce_emojis',
      func: this.announceEmojis.bind(this),
      description: 'announced the emojis that had been collected',
    },
    {
      name: 'remove_emoji',
      func: this.removeEmoji.bind(this),
      description: 'removed the emoji from the current square',
    },
  ]
}
