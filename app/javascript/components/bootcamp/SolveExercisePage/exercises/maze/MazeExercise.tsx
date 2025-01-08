import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'

export default class MazeExercise extends Exercise {
  private mazeLayout: number[][] = []
  private gridSize: number = 0
  private characterPosition: { x: number; y: number } = { x: 0, y: 0 }
  private direction: string = 'down'
  private angle: number = 180
  private duration: number = 200
  private characterSelector: string
  private squareSize: number = 0
  private maze: HTMLElement
  private character: HTMLElement
  private cells: HTMLElement

  private startingAngles = { down: 180, up: 0, left: -90, right: 90 }

  public getState() {
    return {
      direction: this.direction,
      position: [this.characterPosition.x, this.characterPosition.y],
    }
  }

  public getGameResult() {
    return 'win'
  }

  public constructor() {
    super('maze')

    this.cells = document.createElement('div')
    this.cells.classList.add('cells')
    this.container.appendChild(this.cells)

    this.character = document.createElement('div')
    this.character.classList.add('character')
    this.container.appendChild(this.character)
    this.characterSelector = `#${this.view.id} .character`
    this.redrawMaze()
  }

  private redrawMaze(): void {
    this.cells.innerHTML = ''
    this.view.style.setProperty('--gridSize', this.gridSize.toString())

    for (let y = 0; y < this.mazeLayout.length; y++) {
      for (let x = 0; x < this.mazeLayout[y].length; x++) {
        const cell = document.createElement('div')
        cell.classList.add('cell')
        if (this.mazeLayout[y][x] === 1) {
          cell.classList.add('blocked')
        } else if (this.mazeLayout[y][x] === 2) {
          cell.classList.add('start')
        } else if (this.mazeLayout[y][x] === 3) {
          cell.classList.add('target')
        } else if (this.mazeLayout[y][x] === 4) {
          cell.classList.add('bomb')
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
      executionCtx.logicError('Character attempted to move out of bounds')
      executionCtx.updateState('gameOver', true)
      return
    }

    const square = yRow[this.characterPosition.x]
    // If we can't move, blow up
    if (square === undefined) {
      executionCtx.logicError('Character attempted to move out of bounds')
      executionCtx.updateState('gameOver', true)
      return
    }

    // If we've hit a bad square, still animate but also animate color
    if (square === 1) {
      executionCtx.logicError('Character attempted to walk into a wall')
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

  public canTurnLeft(_: ExecutionContext) {
    const { x, y } = this.characterPosition
    let newX = x
    let newY = y

    if (this.direction === 'up') {
      newX -= 1
    } else if (this.direction === 'down') {
      newX += 1
    } else if (this.direction === 'left') {
      newY += 1
    } else if (this.direction === 'right') {
      newY -= 1
    }

    return (
      newX >= 0 &&
      newX < this.gridSize &&
      newY >= 0 &&
      newY < this.gridSize &&
      this.mazeLayout[newY][newX] !== 1
    )
  }

  public canTurnRight(_: ExecutionContext) {
    const { x, y } = this.characterPosition
    let newX = x
    let newY = y

    if (this.direction === 'up') {
      newX += 1
    } else if (this.direction === 'down') {
      newX -= 1
    } else if (this.direction === 'left') {
      newY -= 1
    } else if (this.direction === 'right') {
      newY += 1
    }

    return (
      newX >= 0 &&
      newX < this.gridSize &&
      newY >= 0 &&
      newY < this.gridSize &&
      this.mazeLayout[newY][newX] !== 1
    )
  }

  private canMove(_: ExecutionContext) {
    const { x, y } = this.characterPosition
    let newX = x
    let newY = y

    if (this.direction === 'up') {
      newY -= 1
    } else if (this.direction === 'down') {
      newY += 1
    } else if (this.direction === 'left') {
      newX -= 1
    } else if (this.direction === 'right') {
      newX += 1
    }

    return (
      newX >= 0 &&
      newX < this.gridSize &&
      newY >= 0 &&
      newY < this.gridSize &&
      this.mazeLayout[newY][newX] !== 1
    )
  }

  public setupGrid(layout: number[][]) {
    this.mazeLayout = layout
    this.gridSize = layout.length
    this.squareSize = 100 / layout.length
    this.redrawMaze()
  }
  public setupDirection(direction: string) {
    this.direction = direction
    this.angle = this.startingAngles[direction]
    this.character.style.transform = `rotate(${this.angle}deg)`
  }
  public setupPosition(x: number, y: number) {
    this.characterPosition = { x: x, y: y }
    this.character.style.left = `${this.characterPosition.x * this.squareSize}%`
    this.character.style.top = `${this.characterPosition.y * this.squareSize}%`
  }

  public availableFunctions = [
    {
      name: 'move',
      func: this.move.bind(this),
      description: 'Moves the character one step forward',
    },
    {
      name: 'turn_left',
      func: this.turnLeft.bind(this),
      description: 'Turns the character to the left',
    },
    {
      name: 'turn_right',
      func: this.turnRight.bind(this),
      description: 'Turns the character to the right',
    },
    {
      name: 'can_turn_left',
      func: this.canTurnLeft.bind(this),
      description: 'Checks if the character can turn left',
    },
    {
      name: 'can_turn_right',
      func: this.canTurnRight.bind(this),
      description: 'Checks if the character can turn right',
    },
    {
      name: 'can_move',
      func: this.canMove.bind(this),
      description: 'Checks if the character can move forward',
    },
  ]
}
