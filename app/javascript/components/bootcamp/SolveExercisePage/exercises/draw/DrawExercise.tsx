import { Exercise } from '../Exercise'
import { aToR, rToA } from './utils'
import * as Shapes from './shapes'
import type { ExecutionContext } from '@/interpreter/executor'

class Shape {
  public constructor(public element: SVGElement) {}
}

class Rectangle extends Shape {
  public constructor(
    public x: number,
    public y: number,
    public width: number,
    public height: number,
    element: SVGElement
  ) {
    super(element)
  }
}

class Circle extends Shape {
  public constructor(
    public cx: number,
    public cy: number,
    public radius: number,
    element: SVGElement
  ) {
    super(element)
  }
}

class Ellipse extends Shape {
  public constructor(
    public x: number,
    public y: number,
    public rx: number,
    public ry: number,
    element: SVGElement
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
    element: SVGElement
  ) {
    super(element)
  }
}

export type FillColor =
  | { type: 'hex'; color: string }
  | { type: 'rgb'; color: [number, number, number] }

export default class DrawExercise extends Exercise {
  private canvas: HTMLDivElement
  private shapes: Shape[] = []

  private penColor = '#333333'
  private fillColor: FillColor = { type: 'hex', color: '#ff0000' }

  constructor() {
    super('draw')

    Object.assign(this.view.style, {
      display: 'none',
      position: 'relative',
    })

    const grid = document.createElement('div')
    grid.classList.add('bg-grid')
    this.view.appendChild(grid)

    this.canvas = document.createElement('div')
    this.canvas.classList.add('canvas')
    this.canvas.style.position = 'relative'
    this.view.appendChild(this.canvas)

    this.tooltip = document.createElement('div')
    this.tooltip.classList.add('tooltip')
    Object.assign(this.tooltip.style, {
      whiteSpace: 'nowrap',
      position: 'absolute',
      background: '#333',
      color: '#fff',
      padding: '4px',
      borderRadius: '4px',
      fontSize: '12px',
      pointerEvents: 'none',
      display: 'none',
    })
    this.view.appendChild(this.tooltip)

    this.canvas.addEventListener('mousemove', this.showTooltip.bind(this))
    this.canvas.addEventListener('mouseleave', this.hideTooltip.bind(this))
    this.setBackgroundImage = this.setBackgroundImage.bind(this)
  }

  showTooltip(event: MouseEvent) {
    const rect = this.canvas.getBoundingClientRect()
    const canvasWidth = rect.width
    const canvasHeight = rect.height

    const absX = event.clientX - rect.left
    const absY = event.clientY - rect.top

    const relX = Math.round(aToR(absX, canvasWidth))
    const relY = Math.round(aToR(absY, canvasHeight))

    let tooltipX = absX + 10
    let tooltipY = absY + 10

    // providing these as constant values saves us from recalculating them every time
    // update these values if the tooltip style changes
    // measure max tooltip width/height with the fn below
    // console.log(this.tooltip.getBoundingClientRect().width, this.tooltip.getBoundingClientRect().height)
    const maxTooltipWidth = 75
    const maxTooltipHeight = 32
    // handle tooltip overflow-x
    if (tooltipX + maxTooltipWidth + 5 > canvasWidth) {
      tooltipX = absX - maxTooltipWidth - 10
    }

    // handle tooltip overflow-y
    if (tooltipY + maxTooltipHeight + 5 > canvasHeight) {
      tooltipY = absY - maxTooltipHeight - 10
    }

    this.tooltip.textContent = `X: ${relX}, Y: ${relY}`
    this.tooltip.style.left = `${tooltipX}px`
    this.tooltip.style.top = `${tooltipY}px`
    this.tooltip.style.display = 'block'
  }

  hideTooltip() {
    this.tooltip.style.display = 'none'
  }

  public getState() {
    return {}
  }
  public numElements() {
    return this.shapes.length
  }
  public getRectangleAt(x: number, y: number, width: number, height: number) {
    return this.shapes.find((shape) => {
      if (shape instanceof Rectangle) {
        if (x !== undefined) {
          if (shape.x != x) {
            return false
          }
        }

        if (y !== undefined) {
          if (shape.y != y) {
            return false
          }
        }

        if (width !== undefined) {
          if (shape.width != width) {
            return false
          }
        }
        if (height !== undefined) {
          if (shape.height != height) {
            return false
          }
        }
        return true
      }
    })
  }
  public getCircleAt(cx: number, cy: number, radius: number) {
    return this.shapes.find((shape) => {
      if (shape instanceof Circle) {
        return shape.cx == cx && shape.cy == cy && shape.radius == radius
      }
    })
  }
  public getEllipseAt(x: number, y: number, rx: number, ry: number) {
    return this.shapes.find((shape) => {
      if (shape instanceof Ellipse) {
        return shape.x == x && shape.y == y && shape.rx == rx && shape.ry == ry
      }
    })
  }
  public getTriangleAt(
    x1: number,
    y1: number,
    x2: number,
    y2: number,
    x3: number,
    y3: number
  ) {
    return this.shapes.find((shape) => {
      if (shape instanceof Triangle) {
        const arePointsEqual = (p1, p2) => p1[0] === p2[0] && p1[1] === p2[1]

        const shapePoints = [
          [shape.x1, shape.y1],
          [shape.x2, shape.y2],
          [shape.x3, shape.y3],
        ]
        const points = [
          [x1, y1],
          [x2, y2],
          [x3, y3],
        ]

        const match = (a, b, c) =>
          arePointsEqual(shapePoints[0], a) &&
          arePointsEqual(shapePoints[1], b) &&
          arePointsEqual(shapePoints[2], c)

        return (
          match(points[0], points[1], points[2]) ||
          match(points[0], points[2], points[1]) ||
          match(points[1], points[0], points[2]) ||
          match(points[1], points[2], points[0]) ||
          match(points[2], points[0], points[1]) ||
          match(points[2], points[1], points[0])
        )
      }
    })
  }

  public changePenColor(executionCtx: ExecutionContext, color: string) {
    this.penColor = color
  }
  public fillColorHex(executionCtx: ExecutionContext, color: string) {
    this.fillColor = { type: 'hex', color: color }
  }
  public fillColorRGB(executionCtx: ExecutionContext, red, green, blue) {
    this.fillColor = { type: 'rgb', color: [red, green, blue] }
  }

  public rectangle(
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

  public ellipse(
    executionCtx: ExecutionContext,
    x: number,
    y: number,
    rx: number,
    ry: number
  ) {
    const [absX, absY, absRx, absRy] = [x, y, rx, ry].map((val) => rToA(val))

    const elem = Shapes.ellipse(
      absX,
      absY,
      absRx,
      absRy,
      this.penColor,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const ellipse = new Ellipse(x, y, rx, ry, elem)
    this.shapes.push(ellipse)
    this.animateElement(executionCtx, elem, absX, absY)
    return ellipse
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
    elem: SVGElement,
    absX: number,
    absY: number
  ) {
    const duration = 1
    this.addAnimation({
      targets: `#${this.view.id} #${elem.id}`,
      duration,
      transformations: {
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

  public setBackgroundImage(imageUrl: string | null) {
    if (imageUrl) {
      this.canvas.style.backgroundImage = 'url(' + imageUrl + ')'
      this.canvas.style.backgroundSize = '99.5%'
      this.canvas.style.backgroundPosition = 'center'
    } else {
      this.canvas.style.backgroundImage = 'none'
    }
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
      name: 'rectangle',
      func: this.rectangle.bind(this),
      description:
        'It drew a rectangle at coordinates (${arg1}, ${arg2}) with a width of ${arg3} and a height of ${arg4}.',
    },
    {
      name: 'triangle',
      func: this.triangle.bind(this),
      description:
        'It drew a rectangle with three points: (${arg1}, ${arg2}), (${arg3}, ${arg4}), and (${arg5}, ${arg6}).',
    },
    {
      name: 'circle',
      func: this.circle.bind(this),
      description:
        'It drew a circle with its center at (${arg1}, ${arg2}), and a radius of ${arg3}.',
    },
    {
      name: 'ellipse',
      func: this.ellipse.bind(this),
      description:
        'It drew an ellipse with its center at (${arg1}, ${arg2}), a radial width of ${arg3}, and a radial height of ${arg4}.',
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
      name: 'fill_color_hex',
      func: this.fillColorHex.bind(this),
      description: 'Changes the fill color using a hex string',
    },
    {
      name: 'fill_color_rgb',
      func: this.fillColorRGB.bind(this),
      description: 'Changes the fill color using three RGB values',
    },
  ]
}
