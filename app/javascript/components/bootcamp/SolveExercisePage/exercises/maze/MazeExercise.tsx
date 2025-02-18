import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import cloneDeep from 'lodash.clonedeep'
import { isString } from '@/interpreter/checks'
import { randomEmoji } from '../../test-runner/generateAndRunTestSuite/genericSetupFunctions'
import { isEqual } from 'lodash'

type Cell = 0 | 1 | 2 | 3 | 4 | 5 | 6 | string
export default class MazeExercise extends Exercise {
  private mazeLayout: Cell[][] = []
  private gridSize: number = 0
  private characterPosition: { x: number; y: number } = { x: 0, y: 0 }
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
    this.randomEmojis = []
  }

  // Setup Functions
  public setupGrid(_: ExecutionContext, layout: Cell[][]) {
    layout = this.processRandomEmojis(layout)
    this.mazeLayout = cloneDeep(layout)
    this.initialMazeLayout = cloneDeep(layout)
    this.gridSize = layout.length
    this.squareSize = 100 / layout.length
    this.redrawMaze()
  }
  private processRandomEmojis(layout: Cell[][]) {
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
  public enableEmojiMode(_: ExecutionContext) {
    this.emojiMode = true
  }

  private redrawMaze(): void {
    this.cells.innerHTML = ''
    this.view.style.setProperty('--gridSize', this.gridSize.toString())

    for (let y = 0; y < this.mazeLayout.length; y++) {
      for (let x = 0; x < this.mazeLayout[y].length; x++) {
        const cell = document.createElement('div')
        cell.classList.add('cell', `cell-${y}-${x}`)
        const square = this.mazeLayout[y][x]
        if (square === 0) {
        } else if (square === 1) {
          cell.classList.add('blocked')
        } else if (square === 2) {
          cell.classList.add('start')
        } else if (square === 3) {
          cell.classList.add('target')
        } else if (square === 4) {
          cell.classList.add('fire')
        } else if (square === 5) {
          cell.classList.add('poop')
        } else {
          const child = document.createElement('div')
          child.classList.add('emoji')
          child.textContent = square.toString()
          cell.appendChild(child)
        }
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
    if (square === 1) {
      executionCtx.logicError('Ouch! You walked into a wall!')
      executionCtx.updateState('gameOver', true)
      return
    }

    // If you hit an invalid square, blow up.
    else if (square === 4) {
      executionCtx.logicError('Ouch! You walked into the fire!')
      executionCtx.updateState('gameOver', true)
      return
    }

    // If you hit an invalid square, blow up.
    else if (square === 5) {
      executionCtx.logicError('Ewww! You walked into the poop! 💩💩💩')
      executionCtx.updateState('gameOver', true)
      return
    } else if (square === 3) {
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

    if (!isString(square)) {
      executionCtx.logicError(
        'You tried to remove an emoji from a square that does not have one.'
      )
    }

    yRow[this.characterPosition.x] = 0

    const emojiSelector = `#${this.view.id} .cell-${this.characterPosition.y}-${this.characterPosition.x} .emoji`
    this.addAnimation({
      targets: emojiSelector,
      duration: 1,
      transformations: {
        opacity: 0,
      },
      offset: executionCtx.getCurrentTime(),
    })
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

  private gameOverLoss(executionCtx: ExecutionContext) {
    executionCtx.updateState('gameOver', true)

    this.addAnimation({
      targets: this.characterSelector,
      duration: 200,
      transformations: {
        backgroundColor: `#f00`,
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

  private describePosition(x: number, y: number) {
    if (x >= 0 && x < this.gridSize && y >= 0 && y < this.gridSize) {
      return this.describeSquare(this.mazeLayout[y][x])
    }

    return this.emojiMode ? '🧱' : 'wall'
  }

  public canMoveToSquare(square: string) {
    if (square === 'wall' || square === 'fire') {
      return false
    }
    return true
  }
  public canTurnLeft(_: ExecutionContext) {
    return this.canMoveToSquare(this.lookLeft())
  }
  public canTurnRight(_: ExecutionContext) {
    return this.canMoveToSquare(this.lookRight())
  }
  public canMove(_: ExecutionContext) {
    return this.canMoveToSquare(this.lookAhead())
  }

  public lookLeft() {
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

    return this.describePosition(x, y)
  }

  public lookRight() {
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

    return this.describePosition(x, y)
  }

  private lookAhead() {
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

    return this.describePosition(x, y)
  }

  private look(executionCtx: ExecutionContext, direction: string) {
    if (direction === 'left') {
      return this.lookLeft()
    }
    if (direction === 'right') {
      return this.lookRight()
    }
    if (direction === 'ahead') {
      return this.lookAhead()
    }
    if (direction === 'down') {
      return this.describePosition(
        this.characterPosition.x,
        this.characterPosition.y
      )
    } else {
      executionCtx.logicError(
        `You asked the blob to look in a direction it doesn't know about. It can only look \"left\", \"right\", or \"ahead\". You asked it to look \"${direction}\".`
      )
    }
  }

  public getInitialMaze(_: ExecutionContext) {
    return this.initialMazeLayout.map((row) => row.map(this.describeSquare))
  }
  private describeSquare(cell: Cell) {
    if (this.emojiMode) {
      if (cell === 0) return '⬜'
      if (cell === 1) return '🧱'
      if (cell === 2) return '⭐'
      if (cell === 3) return '🏁'
      if (cell === 4) return '🔥'
      if (cell === 5) return '💩'
    } else {
      if (cell === 0) return 'empty'
      if (cell === 1) return 'wall'
      if (cell === 2) return 'start'
      if (cell === 3) return 'target'
      if (cell === 4) return 'fire'
      if (cell === 5) return 'poop'
    }
    return cell
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
  public announceEmojis(_: ExecutionContext, emojis) {
    this.collectedEmojis = emojis
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
      name: 'get_maze',
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
