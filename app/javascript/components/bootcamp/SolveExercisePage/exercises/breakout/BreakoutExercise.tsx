import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { offset } from '@popperjs/core'

export default class BreakoutExercise extends Exercise {
  private Block = (() => {
    const createBlock = (
      _: ExecutionContext,
      block: Jiki.JikiObject,
      x: number,
      y: number
    ) => {
      const div = document.createElement('div')
      div.classList.add('block')
      div.id = `block-${block.objectId}`
      div.style.left = `${x}%`
      div.style.top = `${y}%`
      this.view.appendChild(div)
    }
    const animateColor = (
      executionContext: ExecutionContext,
      block: Jiki.JikiObject,
      colorHex: string
    ) => {
      this.addAnimation({
        targets: `#${this.view.id} #block-${block.objectId}`,
        duration: 1,
        transformations: {
          backgroundColor: colorHex,
        },
        offset: executionContext.getCurrentTime(),
      })
    }

    const Block = new Jiki.Class('Block')
    Block.addConstructor(function (
      this: Jiki.Instance,
      executionContext: ExecutionContext,
      x: Jiki.Number,
      y: Jiki.Number
    ) {
      this.fields.set('x', x)
      this.fields.set('y', x)
      createBlock(executionContext, this, x.value, y.value)
    })
    Block.addSetter(
      'color',
      function (
        this: Jiki.Instance,
        executionContext: ExecutionContext,
        value: Jiki.Object
      ): void {
        if (!(value instanceof Jiki.String)) {
          executionContext.logicError('Color must be a string')
        }
        this.fields.set('color', value)
        animateColor(executionContext, this, value.value)
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

  public constructor() {
    super('breakout')

    this.container = document.createElement('div')
    this.view.appendChild(this.container)
  }

  // Setup Functions
  public setupBlocks(_: ExecutionContext, layout: [][]) {}

  public availableClasses = [this.Block]

  public availableFunctions = []
}
