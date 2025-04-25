import { Exercise } from '../Exercise'
import { aToR, rToA } from './utils'
import * as Shapes from './shapes'
import * as Jiki from '@/interpreter/jikiObjects'
import type { ExecutionContext } from '@/interpreter/executor'
import { InterpretResult } from '@/interpreter/interpreter'
import {
  assertAllArgumentsAreVariables,
  checkCanvasCoverage,
  checkUniqueColoredLines,
  checkUniqueColoredCircles,
  checkUniqueColoredRectangles,
} from './checks'
import {
  Shape,
  Circle,
  Line,
  Rectangle,
  Triangle,
  Color,
  Ellipse,
} from './shapes'
import {
  getCircleAt,
  getLineAt,
  getEllipseAt,
  getRectangleAt,
  getTriangleAt,
} from './retrievers'

export default class DrawExercise extends Exercise {
  private canvas: HTMLDivElement
  protected shapes: Shape[] = []
  private visibleShapes: Shape[] = []

  protected strokeColor: Color = { type: 'hex', color: '#333333' }
  protected strokeWidth = 0
  protected fillColor: Color = { type: 'hex', color: '#ff0000' }

  constructor(slug = 'draw') {
    super(slug)
    this.showAnimationsOnInfiniteLoops = false

    Object.assign(this.view.style, {
      display: 'none',
      position: 'relative',
    })

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
      zIndex: '99999',
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
  public numElements(_: InterpretResult) {
    return this.shapes.length
  }
  public getLineAt(
    _: InterpretResult,
    x1: number,
    y1: number,
    x2: number,
    y2: number
  ) {
    return getLineAt(this.shapes, x1, y1, x2, y2)
  }
  public getRectangleAt(
    _: InterpretResult,
    x: number,
    y: number,
    width: number,
    height: number
  ) {
    return getRectangleAt(this.shapes, x, y, width, height)
  }
  public getCircleAt(
    _: InterpretResult,
    cx: number,
    cy: number,
    radius: number
  ) {
    return getCircleAt(this.shapes, cx, cy, radius)
  }
  public getEllipseAt(
    _: InterpretResult,
    x: number,
    y: number,
    rx: number,
    ry: number
  ) {
    return getEllipseAt(this.shapes, x, y, rx, ry)
  }
  public getTriangleAt(
    _: InterpretResult,
    x1: number,
    y1: number,
    x2: number,
    y2: number,
    x3: number,
    y3: number
  ) {
    return getTriangleAt(this.shapes, x1, y1, x2, y2, x3, y3)
  }

  // These all delegate to checks.
  public checkUniqueColoredLines(_: InterpretResult, count: number) {
    return checkUniqueColoredLines(this.shapes, count)
  }

  public checkUniqueColoredRectangles(_: InterpretResult, count: number) {
    return checkUniqueColoredRectangles(this.shapes, count)
  }

  public checkUniqueColoredCircles(_: InterpretResult, count: number) {
    return checkUniqueColoredCircles(this.shapes, count)
  }

  public checkCanvasCoverage(_: InterpretResult, requiredPercentage) {
    return checkCanvasCoverage(this.shapes, requiredPercentage)
  }

  public assertAllArgumentsAreVariables(interpreterResult: InterpretResult) {
    return assertAllArgumentsAreVariables(interpreterResult)
  }
  public strokeColorHex(_: ExecutionContext, color: Jiki.String) {
    this.strokeColor = { type: 'hex', color: color.value }
  }
  public setStrokeWidth(_: ExecutionContext, width: Jiki.Number) {
    this.strokeWidth = width.value
  }
  public changeStrokeWidth(_: ExecutionContext, width: number) {
    this.strokeWidth = width
  }
  public fillColorHex(_: ExecutionContext, color: Jiki.String) {
    this.fillColor = { type: 'hex', color: color.value }
  }
  public fillColorRGB(
    executionCtx: ExecutionContext,
    red: Jiki.JikiObject,
    green: Jiki.JikiObject,
    blue: Jiki.JikiObject
  ) {
    if (
      !(red instanceof Jiki.Number) ||
      !(green instanceof Jiki.Number) ||
      !(blue instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    if (red.value < 0 || red.value > 255) {
      return executionCtx.logicError('Red must be between 0 and 255')
    }
    if (green.value < 0 || green.value > 255) {
      return executionCtx.logicError('Green must be between 0 and 255')
    }
    if (blue.value < 0 || blue.value > 255) {
      return executionCtx.logicError('Blue must be between 0 and 255')
    }
    this.fillColor = {
      type: 'rgb',
      color: [red.value, green.value, blue.value],
    }
  }
  public fillColorRGBA(
    executionCtx: ExecutionContext,
    red: Jiki.JikiObject,
    green: Jiki.JikiObject,
    blue: Jiki.JikiObject,
    alpha: Jiki.JikiObject
  ) {
    if (
      !(red instanceof Jiki.Number) ||
      !(green instanceof Jiki.Number) ||
      !(blue instanceof Jiki.Number) ||
      !(alpha instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    if (red.value < 0 || red.value > 255) {
      return executionCtx.logicError('Red must be between 0 and 255')
    }
    if (green.value < 0 || green.value > 255) {
      return executionCtx.logicError('Green must be between 0 and 255')
    }
    if (blue.value < 0 || blue.value > 255) {
      return executionCtx.logicError('Blue must be between 0 and 255')
    }
    if (alpha.value < 0 || alpha.value > 1) {
      return executionCtx.logicError('Alpha must be between 0 and 1')
    }
    this.fillColor = {
      type: 'rgba',
      color: [red.value, green.value, blue.value, alpha.value],
    }
  }
  public fillColorHSL(
    executionCtx: ExecutionContext,
    h: Jiki.JikiObject,
    s: Jiki.JikiObject,
    l: Jiki.JikiObject
  ) {
    if (
      !(h instanceof Jiki.Number) ||
      !(s instanceof Jiki.Number) ||
      !(l instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    if (h.value < 0 || h.value > 360) {
      return executionCtx.logicError('Hue must be between 0 and 360')
    }
    if (s.value < 0 || s.value > 100) {
      return executionCtx.logicError('Saturation must be between 0 and 100')
    }
    if (l.value < 0 || l.value > 100) {
      return executionCtx.logicError('Luminosity must be between 0 and 100')
    }
    this.fillColor = { type: 'hsl', color: [h.value, s.value, l.value] }
  }
  public rectangle(
    executionCtx: ExecutionContext,
    x: Jiki.JikiObject,
    y: Jiki.JikiObject,
    width: Jiki.JikiObject,
    height: Jiki.JikiObject
  ): void {
    if (
      !(x instanceof Jiki.Number) ||
      !(y instanceof Jiki.Number) ||
      !(width instanceof Jiki.Number) ||
      !(height instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    if (width.value < 0) {
      return executionCtx.logicError('Width must be greater than 0')
    }
    if (height.value < 0) {
      return executionCtx.logicError('Height must be greater than 0')
    }
    const [absX, absY, absWidth, absHeight] = [
      x.value,
      y.value,
      width.value,
      height.value,
    ].map((val) => rToA(val))

    const elem = Shapes.rect(
      absX,
      absY,
      absWidth,
      absHeight,
      this.strokeColor,
      this.strokeWidth,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const rect = new Rectangle(
      x.value,
      y.value,
      width.value,
      height.value,
      this.strokeColor,
      this.fillColor,
      elem
    )
    this.shapes.push(rect)
    this.visibleShapes.push(rect)
    this.animateShapeIntoView(executionCtx, elem)
    // return rect
  }
  public line(
    executionCtx: ExecutionContext,
    x1: Jiki.JikiObject,
    y1: Jiki.JikiObject,
    x2: Jiki.JikiObject,
    y2: Jiki.JikiObject
  ): void {
    if (
      !(x1 instanceof Jiki.Number) ||
      !(y1 instanceof Jiki.Number) ||
      !(x2 instanceof Jiki.Number) ||
      !(y2 instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    const [absX1, absY1, absX2, absY2] = [
      x1.value,
      y1.value,
      x2.value,
      y2.value,
    ].map((val) => rToA(val))

    const elem = Shapes.line(
      absX1,
      absY1,
      absX2,
      absY2,
      this.strokeColor,
      this.strokeWidth,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const line = new Line(
      x1.value,
      y1.value,
      x2.value,
      y2.value,
      this.strokeColor,
      this.fillColor,
      elem
    )
    this.shapes.push(line)
    this.visibleShapes.push(line)
    this.animateShapeIntoView(executionCtx, elem)
  }

  public circle(
    executionCtx: ExecutionContext,
    x: Jiki.JikiObject,
    y: Jiki.JikiObject,
    radius: Jiki.JikiObject
  ): void {
    if (
      !(x instanceof Jiki.Number) ||
      !(y instanceof Jiki.Number) ||
      !(radius instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    const [absX, absY, absRadius] = [x.value, y.value, radius.value].map(
      (val) => rToA(val)
    )

    const elem = Shapes.circle(
      absX,
      absY,
      absRadius,
      this.strokeColor,
      this.strokeWidth,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const circle = new Circle(
      x.value,
      y.value,
      radius.value,
      this.strokeColor,
      this.fillColor,
      elem
    )
    this.shapes.push(circle)
    this.visibleShapes.push(circle)
    this.animateShapeIntoView(executionCtx, elem)
    // return circle
  }

  public ellipse(
    executionCtx: ExecutionContext,
    x: Jiki.JikiObject,
    y: Jiki.JikiObject,
    rx: Jiki.JikiObject,
    ry: Jiki.JikiObject
  ): void {
    if (
      !(x instanceof Jiki.Number) ||
      !(y instanceof Jiki.Number) ||
      !(rx instanceof Jiki.Number) ||
      !(ry instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }

    const [absX, absY, absRx, absRy] = [
      x.value,
      y.value,
      rx.value,
      ry.value,
    ].map((val) => rToA(val))

    const elem = Shapes.ellipse(
      absX,
      absY,
      absRx,
      absRy,
      this.strokeColor,
      this.strokeWidth,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const ellipse = new Ellipse(
      x.value,
      y.value,
      rx.value,
      ry.value,
      this.strokeColor,
      this.fillColor,
      elem
    )
    this.shapes.push(ellipse)
    this.visibleShapes.push(ellipse)
    this.animateShapeIntoView(executionCtx, elem)
    // return ellipse
  }

  public triangle(
    executionCtx: ExecutionContext,
    x1: Jiki.JikiObject,
    y1: Jiki.JikiObject,
    x2: Jiki.JikiObject,
    y2: Jiki.JikiObject,
    x3: Jiki.JikiObject,
    y3: Jiki.JikiObject
  ): void {
    if (
      !(x1 instanceof Jiki.Number) ||
      !(y1 instanceof Jiki.Number) ||
      !(x2 instanceof Jiki.Number) ||
      !(y2 instanceof Jiki.Number) ||
      !(x3 instanceof Jiki.Number) ||
      !(y3 instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All inputs must be numbers')
    }
    const [absX1, absY1, absX2, absY2, absX3, absY3] = [
      x1.value,
      y1.value,
      x2.value,
      y2.value,
      x3.value,
      y3.value,
    ].map((val) => rToA(val))

    const elem = Shapes.triangle(
      absX1,
      absY1,
      absX2,
      absY2,
      absX3,
      absY3,
      this.strokeColor,
      this.strokeWidth,
      this.fillColor
    )
    this.canvas.appendChild(elem)

    const triangle = new Triangle(
      x1.value,
      y1.value,
      x2.value,
      y2.value,
      x3.value,
      y3.value,
      this.strokeColor,
      this.fillColor,
      elem
    )
    this.shapes.push(triangle)
    this.visibleShapes.push(triangle)
    this.animateShapeIntoView(executionCtx, elem)
    // return triangle
  }

  protected animateShapeIntoView(
    executionCtx: ExecutionContext,
    elem: SVGElement
  ) {
    this.animateIntoView(executionCtx, `#${this.view.id} #${elem.id}`)
  }
  protected animateShapeOutOfView(
    executionCtx: ExecutionContext,
    elem: SVGElement
  ) {
    this.animateOutOfView(executionCtx, `#${this.view.id} #${elem.id}`)
  }

  public clear(executionCtx: ExecutionContext) {
    const duration = 1
    this.visibleShapes.forEach((shape) => {
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

    this.visibleShapes = []
  }

  public setBackgroundImage(_: ExecutionContext, imageUrl: string | null) {
    if (imageUrl) {
      this.canvas.style.backgroundImage = 'url(' + imageUrl + ')'
      this.canvas.style.backgroundSize = 'cover'
      this.canvas.style.backgroundPosition = 'center'
    } else {
      this.canvas.style.backgroundImage = 'none'
    }
  }

  public availableFunctions = [
    {
      name: 'random_number',
      func: (_: any, min: Jiki.Number, max: Jiki.Number): Jiki.Number => {
        return new Jiki.Number(
          Math.floor(Math.random() * (max.value - min.value + 1)) + min.value
        )
      },
      description: 'generated a random number between ${arg1} and ${arg2}',
    },

    {
      name: 'rectangle',
      func: this.rectangle.bind(this),
      description:
        'drew a rectangle at coordinates (${arg1}, ${arg2}) with a width of ${arg3} and a height of ${arg4}',
    },
    {
      name: 'triangle',
      func: this.triangle.bind(this),
      description:
        'drew a rectangle with three points: (${arg1}, ${arg2}), (${arg3}, ${arg4}), and (${arg5}, ${arg6})',
    },
    {
      name: 'circle',
      func: this.circle.bind(this),
      description:
        'drew a circle with its center at (${arg1}, ${arg2}), and a radius of ${arg3}',
    },
    {
      name: 'ellipse',
      func: this.ellipse.bind(this),
      description:
        'drew an ellipse with its center at (${arg1}, ${arg2}), a radial width of ${arg3}, and a radial height of ${arg4}',
    },
    {
      name: 'clear',
      func: this.clear.bind(this),
      description: 'cleared the canvas',
    },
    {
      name: 'fill_color_hex',
      func: this.fillColorHex.bind(this),
      description: 'changed the fill color using a hex string',
    },
    {
      name: 'fill_color_rgb',
      func: this.fillColorRGB.bind(this),
      description: 'changed the fill color using red, green and blue values',
    },
    {
      name: 'fill_color_hsl',
      func: this.fillColorHSL.bind(this),
      description:
        'changed the fill color using hue, saturation and lumisity values',
    },
  ]
}
