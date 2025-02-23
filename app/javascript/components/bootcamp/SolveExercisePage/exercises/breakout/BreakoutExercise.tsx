import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { offset } from '@popperjs/core'

type BallInstance = Jiki.Instance & {}
type BlockInstance = Jiki.Instance & {}
export default class BreakoutExercise extends Exercise {
  private Ball = (() => {
    const createBall = (executionCtx: ExecutionContext, ball: BallInstance) => {
      const div = document.createElement('div')
      div.classList.add('ball')
      div.id = `ball-${ball.objectId}`
      div.style.left = `${ball.getUnwrappedField('x')}%`
      div.style.top = `${ball.getUnwrappedField('y')}%`
      div.style.opacity = '0'
      this.view.appendChild(div)
      this.animateIntoView(
        `#${this.view.id} #ball-${ball.objectId}`,
        executionCtx.getCurrentTime()
      )
    }

    const Ball = new Jiki.Class('Ball')
    Ball.addConstructor(function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext
    ) {
      this.fields['x'] = new Jiki.Number(50)
      this.fields['y'] = new Jiki.Number(95)
      this.fields['y_velocity'] = new Jiki.Number(-1)
      this.fields['x_velocity'] = new Jiki.Number(-1)
      createBall(executionCtx, this)
    })
    Ball.addGetter('x')
    Ball.addGetter('y')
    Ball.addGetter('x_velocity')
    Ball.addSetter('x_velocity')
    Ball.addGetter('y_velocity')
    Ball.addSetter('y_velocity')

    return Ball
  })()

  private Block = (() => {
    const createBlock = (
      executionCtx: ExecutionContext,
      block: BlockInstance
    ) => {
      const div = document.createElement('div')
      div.classList.add('block')
      div.id = `block-${block.objectId}`
      div.style.left = `${block.getUnwrappedField('x')}%`
      div.style.top = `${block.getUnwrappedField('y')}%`
      div.style.opacity = '0'
      this.view.appendChild(div)

      this.animateIntoView(
        `#${this.view.id} #block-${block.objectId}`,
        executionCtx.getCurrentTime()
      )
    }
    const animateColor = (
      executionCtx: ExecutionContext,
      block: Jiki.JikiObject,
      colorHex: string
    ) => {
      this.addAnimation({
        targets: `#${this.view.id} #block-${block.objectId}`,
        duration: 1,
        transformations: {
          backgroundColor: colorHex,
        },
        offset: executionCtx.getCurrentTime(),
      })
    }

    const Block = new Jiki.Class('Block')
    Block.addConstructor(function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      x: Jiki.Number,
      y: Jiki.Number
    ) {
      this.fields['x'] = x
      this.fields['y'] = y
      createBlock(executionCtx, this)
    })
    Block.addSetter(
      'color',
      function (
        this: Jiki.Instance,
        executionCtx: ExecutionContext,
        value: Jiki.JikiObject
      ): void {
        if (!(value instanceof Jiki.String)) {
          return executionCtx.logicError('Color must be a string')
        }
        this.fields['color'] = value
        animateColor(executionCtx, this, value.value)
      }
    )

    return Block
  })()

  public getState() {
    return {}
  }

  public getFalse() {
    return false
  }

  public moveBall(executionCtx: ExecutionContext, ball: BallInstance) {
    const x = ball.getUnwrappedField('x')
    const y = ball.getUnwrappedField('y')
    const x_velocity = ball.getUnwrappedField('x_velocity')
    const y_velocity = ball.getUnwrappedField('y_velocity')

    ball.setField('x', new Jiki.Number(x + x_velocity))
    ball.setField('y', new Jiki.Number(y + y_velocity))

    if (x < 0) {
      executionCtx.logicError(
        'Oh no! The ball moved off the left of the screen'
      )
    }
    if (x > 100) {
      executionCtx.logicError(
        'Oh no! The ball moved off the right of the screen'
      )
    }
    if (y < 0) {
      executionCtx.logicError('Oh no! The ball moved off the top of the screen')
    }
    if (y > 100) {
      executionCtx.logicError(
        'Oh no! The ball moved off the bottom of the screen'
      )
    }

    this.addAnimation({
      targets: `#${this.view.id} #ball-${ball.objectId}`,
      duration: 20,
      transformations: {
        left: `${ball.getUnwrappedField('x')}%`,
        top: `${ball.getUnwrappedField('y')}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
  }

  public constructor() {
    super('breakout')

    this.container = document.createElement('div')
    this.view.appendChild(this.container)
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
