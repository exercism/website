import React from 'react'
import { Exercise } from '../Exercise'
import { rToA } from './utils'
import * as Shapes from './shapes'
import type { ExecutionContext } from '@/interpreter/executor'

class Shape {
  public constructor(public element: HTMLElement) {}
}

class Rectangle extends Shape {
  public constructor(
    public x: number,
    public y: number,
    public width: number,
    public height: number,
    element: HTMLElement
  ) {
    super(element)
  }
}

class Circle extends Shape {
  public constructor(
    public x: number,
    public y: number,
    public radius: number,
    element: HTMLElement
  ) {
    super(element)
  }
}

class Triangle extends Shape {
  public constructor(
    public x1: number,
    public y1: number,
    public x2: number,
    public y2: number,
    public x3: number,
    public y3: number,
    element: HTMLElement
  ) {
    super(element)
  }
}

export default class DrawExercise extends Exercise {
  private canvas: HTMLDivElement
  private shapes: Shape[] = []

  private penColor = '#333333'
  private fillColor = '#ff0000'

  constructor() {
    super('draw')

    Object.assign(this.view.style, {
      display: 'none',
    })

    const grid = document.createElement('div')
    grid.classList.add('bg-grid')
    this.view.appendChild(grid)

    this.canvas = document.createElement('div')
    this.canvas.classList.add('canvas')
    this.view.appendChild(this.canvas)
  }

  public getState() {
    return {}
  }
  public numElements() {
    return this.shapes.length
  }
  public getRectAt(x: number, y: number, width: number, height: number) {
    return this.shapes.find((shape) => {
      if (shape instanceof Rectangle) {
        return (
          shape.x == x &&
          shape.y == y &&
          shape.width == width &&
          shape.height == height
        )
      }
    })
  }

  public changePenColor(executionCtx: ExecutionContext, color: string) {
    this.penColor = color
  }
  public changeFillColor(executionCtx: ExecutionContext, color: string) {
    this.fillColor = color
  }

  public rect(
    executionCtx: ExecutionContext,
    x: number,
    y: number,
    width: number,
    height: number
  ): Rectangle {
    const [absX, absY, absWidth, absHeight] = [x, y, width, height].map((val) =>
      rToA(val)
    )

    const elem = Shapes.rect(
      absX,
      absY,
      absWidth,
      absHeight,
      this.penColor,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const rect = new Rectangle(x, y, width, height, elem)
    this.shapes.push(rect)
    this.animateElement(executionCtx, elem, absX, absY)
    return rect
  }

  public circle(
    executionCtx: ExecutionContext,
    x: number,
    y: number,
    radius: number
  ): Circle {
    const [absX, absY, absRadius] = [x, y, radius].map((val) => rToA(val))

    const elem = Shapes.circle(
      absX,
      absY,
      absRadius,
      this.penColor,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const circle = new Circle(x, y, radius, elem)
    this.shapes.push(circle)
    this.animateElement(executionCtx, elem, absX, absY)
    return circle
  }

  public triangle(
    executionCtx: ExecutionContext,
    x1: number,
    y1: number,
    x2: number,
    y2: number,
    x3: number,
    y3: number
  ): Triangle {
    const [absX1, absY1, absX2, absY2, absX3, absY3] = [
      x1,
      y1,
      x2,
      y2,
      x3,
      y3,
    ].map((val) => rToA(val))

    const elem = Shapes.triangle(
      absX1,
      absY1,
      absX2,
      absY2,
      absX3,
      absY3,
      this.penColor,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const triangle = new Triangle(x1, y1, x2, y2, x3, y3, elem)
    this.shapes.push(triangle)
    this.animateElement(executionCtx, elem, absX1, absY1)
    return triangle
  }

  public move(
    executionCtx: ExecutionContext,
    id: string,
    xTarget: number,
    yTarget: number,
    concurrent: boolean = false
  ) {
    const duration = 500
    // this.addAnimation(executionCtx, {
    //   targets: id,
    //   duration,
    //   transformations: {
    //     top: xTarget,
    //     left: yTarget,
    //   },
    //   offset: executionCtx.time,
    // });

    // if (!concurrent) {
    //   executionCtx.time += duration;
    // }
  }

  public polygon(x: number, y: number, radius: number, sides: number): void {
    // center the polygon
    ;[x, y] = [x, y].map((val) => val - radius)

    const [absX, absY, absRadius] = [x, y, radius].map((val) => rToA(val))

    const polygon = Shapes.polygon(absX, absY, absRadius, sides)
    const duration = 15

    // this.addAnimation(executionCtx, {
    //   targets: `#polygon${elementSerial}`,
    //   duration,
    //   transformations: {
    //     top: y,
    //     left: x,
    //     opacity: 1,
    //   },
    //   offset: executionCtx.time,
    // });

    // executionCtx.time += duration;
  }

  private animateElement(
    executionCtx: ExecutionContext,
    elem: HTMLElement,
    absX: string,
    absY: string
  ) {
    const duration = 5
    this.addAnimation({
      targets: `#${this.view.id} #${elem.id}`,
      duration,
      transformations: {
        top: absY,
        left: absX,
        opacity: 1,
      },
      offset: executionCtx.getCurrentTime(),
    })

    executionCtx.fastForward(duration)
  }

  public clear(executionCtx: ExecutionContext) {
    const duration = 1
    this.shapes.forEach((shape) => {
      this.addAnimation({
        targets: `#${this.view.id} #${shape.element.id}`,
        duration,
        transformations: {
          opacity: 0,
        },
        offset: executionCtx.getCurrentTime(),
      })
    })
    executionCtx.fastForward(duration)

    this.shapes = []
  }

  public availableFunctions = [
    {
      name: 'rand',
      func: (_: any, min: number, max: number) => {
        return Math.floor(Math.random() * (max - min + 1)) + min
      },
      description: 'Gives a random number between ${arg1} and ${arg2}.',
    },
    {
      name: 'rect',
      func: this.rect.bind(this),
      description:
        'It drew a rectangle at coordinates (${arg1}, ${arg2}) with a width of ${arg3} and a height of ${arg4}.',
    },
    {
      name: 'triangle',
      func: this.triangle.bind(this),
      description: 'Draws a triangle at the specified position.',
    },
    {
      name: 'polygon',
      func: this.polygon.bind(this),
      description: 'Draws a polygon at the specified position.',
    },
    {
      name: 'clear',
      func: this.clear.bind(this),
      description: 'Clears the canvas.',
    },
    {
      name: 'circle',
      func: this.circle.bind(this),
      description: 'Draws a circle at the specified position.',
    },
    {
      name: 'move',
      func: this.move.bind(this),
      description: 'Moves an element to the specified position.',
    },
    {
      name: 'change_pen_color',
      func: this.changePenColor.bind(this),
      description: 'Changes the pen color',
    },
    {
      name: 'change_fill_color',
      func: this.changeFillColor.bind(this),
      description: 'Changes the fill color',
    },
  ]
}
