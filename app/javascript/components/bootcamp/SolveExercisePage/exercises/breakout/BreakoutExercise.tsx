import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { offset } from '@popperjs/core'
import { InterpretResult } from '@/interpreter/interpreter'
import { buildBlock, type BlockInstance } from './Block'
import { buildBall, type BallInstance } from './Ball'

export default class BreakoutExercise extends Exercise {
  private Block = buildBlock(this)
  private Ball = buildBall(this)

  public constructor() {
    super('breakout')

    this.container = document.createElement('div')
    this.container.classList.add('container')
    this.view.appendChild(this.container)

    this.ballPositions = []
    this.blocks = []
  }

  public getState() {
    return {
      numBlocks: this.blocks.length,
      numSmashedBlocks: this.blocks.filter((block: BlockInstance) =>
        block.getUnwrappedField('smashed')
      ).length,
      numBallPositions: this.ballPositions.length,
    }
  }

  public setDefaultBallRadius(_, radius: number) {
    this.Ball['default_radius'] = radius
  }

  public setDefaultBlockHeight(_, height: number) {
    this.Block['default_height'] = height
  }

  public getFalse() {
    return false
  }

  public didBallAppearAt(_: InterpretResult, cx: number, cy: number) {
    for (const [ballX, ballY] of this.ballPositions) {
      if (
        (cx == null && ballY == cy) ||
        (cy == null && ballX == cx) ||
        (ballX == cx && ballY == cy)
      ) {
        return true
      }
    }
    return false
  }

  public moveBall(executionCtx: ExecutionContext, ball: BallInstance) {
    if (
      this.blocks.length > 0 &&
      this.blocks.every((block: BlockInstance) =>
        block.getUnwrappedField('smashed')
      )
    ) {
      executionCtx.logicError(
        "You shouldn't move the ball when there were no blocks remaining."
      )
    }
    const cx = ball.getUnwrappedField('cx')
    const cy = ball.getUnwrappedField('cy')
    const x_velocity = ball.getUnwrappedField('x_velocity')
    const y_velocity = ball.getUnwrappedField('y_velocity')
    const radius = ball.getUnwrappedField('radius')

    const newCx = cx + x_velocity
    const newCy = cy + y_velocity

    ball.setField('cx', new Jiki.Number(newCx))
    ball.setField('cy', new Jiki.Number(newCy))

    this.ballPositions.push([newCx, newCy])

    if (newCx - radius < 0) {
      executionCtx.logicError(
        'Oh no! The ball moved off the left of the screen'
      )
    }
    if (newCx + radius > 100) {
      executionCtx.logicError(
        'Oh no! The ball moved off the right of the screen'
      )
    }
    if (newCy - radius < 0) {
      executionCtx.logicError('Oh no! The ball moved off the top of the screen')
    }
    if (newCy + radius > 100) {
      executionCtx.logicError(
        'Oh no! The ball moved off the bottom of the screen'
      )
    }

    this.addAnimation({
      targets: `#${this.view.id} #ball-${ball.objectId}`,
      duration: 1,
      transformations: {
        left: `${newCx}%`,
        top: `${newCy}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }

  // Setup Functions
  public setupBlocks(_: ExecutionContext, layout: [][]) {}

  public availableClasses = [this.Block, this.Ball]

  public availableFunctions = [
    {
      name: 'move_ball',
      func: this.moveBall.bind(this),
      description: 'moved the ball by its velocities',
    },
  ]
}
