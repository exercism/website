import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { offset } from '@popperjs/core'
import { InterpretResult } from '@/interpreter/interpreter'

type BallInstance = Jiki.Instance & {}
type BlockInstance = Jiki.Instance & {
  top: Jiki.Number
  left: Jiki.Number
  smashed: Jiki.Boolean
}
export default class BreakoutExercise extends Exercise {
  private Ball = (() => {
    const createBall = (executionCtx: ExecutionContext, ball: BallInstance) => {
      const div = document.createElement('div')
      div.classList.add('ball')
      div.id = `ball-${ball.objectId}`
      div.style.left = `${ball.getUnwrappedField('cx')}%`
      div.style.top = `${ball.getUnwrappedField('cy')}%`
      div.style.width = `${ball.getUnwrappedField('radius') * 2}%`
      div.style.height = `${ball.getUnwrappedField('radius') * 2}%`
      div.style.opacity = '0'
      this.container.appendChild(div)
      this.animateIntoView(
        executionCtx,
        `#${this.view.id} #ball-${ball.objectId}`
      )
    }

    const Ball = new Jiki.Class('Ball')
    Ball['default_radius'] = 3
    Ball.addConstructor(function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext
    ) {
      this.fields['cx'] = new Jiki.Number(50)
      this.fields['cy'] = new Jiki.Number(100 - Ball['default_radius'])
      this.fields['radius'] = new Jiki.Number(Ball['default_radius'])
      this.fields['y_velocity'] = new Jiki.Number(-1)
      this.fields['x_velocity'] = new Jiki.Number(-1)
      createBall(executionCtx, this)
    })
    Ball.addGetter('cx')
    Ball.addGetter('cy')
    Ball.addGetter('radius')
    Ball.addGetter('x_velocity')
    Ball.addGetter('y_velocity')

    function guardVelocity(
      executionCtx: ExecutionContext,
      value: Jiki.JikiObject
    ) {
      if (!(value instanceof Jiki.Number)) {
        return executionCtx.logicError('Velocity must be a number')
      }
      if (value.value == 0) {
        return executionCtx.logicError('Velocity cannot be zero')
      }
    }

    Ball.addSetter(
      'x_velocity',
      function (
        this: BallInstance,
        executionCtx: ExecutionContext,
        value: Jiki.JikiObject
      ) {
        guardVelocity(executionCtx, value)
        this.fields['x_velocity'] = value
      }
    )
    Ball.addSetter(
      'y_velocity',
      function (
        this: BallInstance,
        executionCtx: ExecutionContext,
        value: Jiki.JikiObject
      ) {
        guardVelocity(executionCtx, value)
        this.fields['y_velocity'] = value
      }
    )

    return Ball
  })()

  private Block = (() => {
    const createBlock = (
      executionCtx: ExecutionContext,
      block: BlockInstance
    ) => {
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
    const hideBlock = (
      executionCtx: ExecutionContext,
      block: Jiki.JikiObject
    ) => {
      this.animateOutOfView(
        executionCtx,
        `#${this.view.id} #block-${block.objectId}`,
        { duration: 150, offset: 0 }
      )
    }

    const Block = new Jiki.Class('Block')
    Block['default_height'] = 7
    Block.addConstructor(function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      left: Jiki.Number,
      top: Jiki.Number
    ) {
      this.fields['left'] = left
      this.fields['top'] = top
      this.fields['width'] = new Jiki.Number(16)
      this.fields['height'] = new Jiki.Number(Block['default_height'])
      this.fields['smashed'] = new Jiki.Boolean(false)
      createBlock(executionCtx, this as BlockInstance)
    })
    Block.addGetter('top')
    Block.addGetter('left')
    Block.addGetter('width')
    Block.addGetter('height')
    Block.addGetter('smashed')
    Block.addSetter(
      'smashed',
      function (
        this: Jiki.Instance,
        executionCtx: ExecutionContext,
        value: Jiki.JikiObject
      ): void {
        if (!(value instanceof Jiki.Boolean)) {
          return executionCtx.logicError('Smashed must be true or false')
        }
        this.fields['smashed'] = value
        if (value.value) {
          hideBlock(executionCtx, this)
        }
      }
    )

    return Block
  })()

  public constructor() {
    super('breakout')

    this.container = document.createElement('div')
    this.container.classList.add('container')
    this.view.appendChild(this.container)

    this.ballPositions = []
    this.blocks = []
  }

  public getState() {
    console.log(this.ballPositions.length)
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
