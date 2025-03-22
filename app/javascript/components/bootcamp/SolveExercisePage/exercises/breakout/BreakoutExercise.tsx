import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { offset } from '@popperjs/core'
import { InterpretResult } from '@/interpreter/interpreter'
import { buildBlock, type BlockInstance } from './Block'
import { buildBall, type BallInstance } from './Ball'
import { buildPaddle, PaddleInstance } from './Paddle'
import { buildGame, type GameInstance } from './Game'

export default class BreakoutExercise extends Exercise {
  private Block = buildBlock(this)
  private Ball = buildBall(this)
  private Paddle = buildPaddle(this)
  private Game = buildGame(this)

  public default_ball_radius = 3
  public default_block_height = 7

  public autoDrawBlock = true
  private gameInstance: GameInstance | undefined

  public constructor() {
    super('breakout')

    this.container = document.createElement('div')
    this.container.classList.add('container')
    this.view.appendChild(this.container)

    this.ballPositions = []
    this.paddleBallInteractionCount = 0
    this.blocks = []
  }
  public disableAutoDrawBlock() {
    this.autoDrawBlock = false
  }

  public getState() {
    return {
      numBlocks: this.blocks.length,
      numSmashedBlocks: this.blocks.filter((block: BlockInstance) =>
        block.getUnwrappedField('smashed')
      ).length,
      numBallPositions: this.ballPositions.length,
      paddleBallInteractionCount: this.paddleBallInteractionCount,
    }
  }

  public setDefaultBallRadius(_, radius: number) {
    this.default_ball_radius = radius
  }

  public setDefaultBlockHeight(_, height: number) {
    this.default_block_height = height
  }

  public getFalse() {
    return false
  }

  public timesPaddleTouchedBall(executionCtx: ExecutionContext) {
    this.paddleBallInteractionCount += 1
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
  public drawBlock(executionCtx: ExecutionContext, block: BlockInstance) {
    this.blocks.push(block)

    const div = document.createElement('div')
    div.classList.add('block')
    div.id = `block-${block.objectId}`
    div.style.left = `${block.getUnwrappedField('left')}%`
    div.style.top = `${block.getUnwrappedField('top')}%`
    div.style.width = `${block.getUnwrappedField('width')}%`
    div.style.height = `${block.getUnwrappedField('height')}%`
    div.style.opacity = '0'
    this.container.appendChild(div)

    this.animateIntoView(
      executionCtx,
      `#${this.view.id} #block-${block.objectId}`
    )
  }

  public redrawBall(executionCtx: ExecutionContext, ball: BallInstance) {
    this.addAnimation({
      targets: `#${this.view.id} #ball-${ball.objectId}`,
      duration: 1,
      transformations: {
        left: `${ball.getUnwrappedField('cx')}%`,
        top: `${ball.getUnwrappedField('cy')}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }

  public logBallPaddleInteractions(executionCtx: ExecutionContext) {
    if (this.gameInstance == undefined) {
      return
    }
    const ball = this.gameInstance.getField('ball') as BallInstance
    const paddle = this.gameInstance.getField('paddle') as PaddleInstance
    if (ball == undefined || paddle == undefined) {
      return
    }

    const ballBottom =
      ball.getUnwrappedField('cy') + ball.getUnwrappedField('radius')
    const ballMiddle = ball.getUnwrappedField('cx')
    const paddleTop =
      paddle.getUnwrappedField('cy') - paddle.getUnwrappedField('height') / 2
    const paddleLeft =
      paddle.getUnwrappedField('cx') - paddle.getUnwrappedField('width') / 2
    const paddleRight =
      paddle.getUnwrappedField('cx') + paddle.getUnwrappedField('width') / 2

    if (
      ballBottom == paddleTop &&
      ballMiddle >= paddleLeft &&
      ballMiddle <= paddleRight
    ) {
      this.paddleBallInteractionCount += 1
    } else if (ballBottom == paddleTop) {
      console.log(ballMiddle, paddleLeft, paddleRight)
    }
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

    this.logBallPaddleInteractions(executionCtx)
  }

  // Setup Functions
  public setupBlocks(_: ExecutionContext, layout: [][]) {}

  public availableClasses = [this.Block, this.Ball, this.Game]

  public availableFunctions = [
    {
      name: 'move_ball',
      func: this.moveBall.bind(this),
      description: 'moved the ball by its velocities',
    },
  ]
}
