import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'

export default class BreakoutExercise extends Exercise {
  private Block = (() => {
    const createBlock = (
      executionContext: ExecutionContext,
      x: number,
      y: number
    ) => {
      const block = document.createElement('div')
      block.classList.add('block')
      block.style.left = `${x}%`
      block.style.top = `${y}%`
      this.view.appendChild(block)
    }

    const Block = new Jiki.Class('Block')
    Block.addConstructor(function (
      this: any,
      executionContext: ExecutionContext,
      x: Jiki.Number,
      y: Jiki.Number
    ) {
      this.fields.set('x', x)
      this.fields.set('y', x)
      createBlock(executionContext, x.value, y.value)
    })
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
