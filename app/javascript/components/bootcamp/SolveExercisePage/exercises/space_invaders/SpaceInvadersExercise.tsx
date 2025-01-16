import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'

export default class SpaceInvadersExercise extends Exercise {
  public getState() {
    return {}
  }

  private moveDuration = 100
  private moveStep = 8

  public constructor() {
    super('space-invaders')

    this.laserLeft = 2

    this.laser = document.createElement('div')
    this.laser.classList.add('laser')
    this.view.appendChild(this.laser)
  }

  public runGame(_: any) {
    console.log('running game')
  }

  public moveLeft(executionCtx: ExecutionContext) {
    this.laserLeft -= this.moveStep
    if (this.laserLeft < 0) {
      executionCtx.logicError('Oh no, you tried to move off the edge!')
      executionCtx.updateState('gameOver', true)
    }

    this.addAnimation({
      targets: `#${this.view.id} .laser`,
      duration: this.moveDuration,
      transformations: {
        opacity: 1,
        left: `${this.laserLeft}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(this.moveDuration)
  }

  public moveRight(executionCtx: ExecutionContext) {
    this.laserLeft += this.moveStep
    if (this.laserLeft < 0) {
      executionCtx.logicError('Oh no, you tried to move off the edge!')
      executionCtx.updateState('gameOver', true)
    }

    this.addAnimation({
      targets: `#${this.view.id} .laser`,
      duration: this.moveDuration,
      transformations: {
        opacity: 1,
        left: `${this.laserLeft}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(this.moveDuration)
  }

  public availableFunctions = [
    {
      name: 'runGame',
      func: this.runGame,
      description: '',
    },
    {
      name: 'move_left',
      func: this.moveLeft.bind(this),
      description: '',
    },
    {
      name: 'move_right',
      func: this.moveRight.bind(this),
      description: '',
    },
  ]
}
