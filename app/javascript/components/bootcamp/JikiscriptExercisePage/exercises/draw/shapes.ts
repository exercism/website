export class Shape {
  public constructor(public element: SVGElement) {}
}

export class Line extends Shape {
  public constructor(
    public x1: number,
    public y1: number,
    public x2: number,
    public y2: number,
    public strokeColor: Color,
    public fillColor: Color,
    element: SVGElement
  ) {
    super(element)
  }
}

export class Rectangle extends Shape {
  public constructor(
    public x: number,
    public y: number,
    public width: number,
    public height: number,
    public strokeColor: Color,
    public fillColor: Color,
    element: SVGElement
  ) {
    super(element)
  }
}

export class Circle extends Shape {
  public constructor(
    public cx: number,
    public cy: number,
    public radius: number,
    public strokeColor: Color,
    public fillColor: Color,
    element: SVGElement
  ) {
    super(element)
  }
}

export class Ellipse extends Shape {
  public constructor(
    public x: number,
    public y: number,
    public rx: number,
    public ry: number,
    public strokeColor: Color,
    public fillColor: Color,
    element: SVGElement
  ) {
    super(element)
  }
}

export class Triangle extends Shape {
  public constructor(
    public x1: number,
    public y1: number,
    public x2: number,
    public y2: number,
    public x3: number,
    public y3: number,
    public strokeColor: Color,
    public fillColor: Color,
    element: SVGElement
  ) {
    super(element)
  }
}

export type Color =
  | { type: 'hex'; color: string }
  | { type: 'rgb'; color: [number, number, number] }
  | { type: 'rgba'; color: [number, number, number, number] }
  | { type: 'hsl'; color: [number, number, number] }

const svgNS = 'http://www.w3.org/2000/svg'

function createSVG(children) {
  const svg = document.createElementNS(svgNS, 'svg')

  // Create the SVG element
  svg.setAttribute('viewBox', `0 0 100 100`) // Set viewBox for relative coordinates
  svg.setAttribute('overflow', 'visible')

  svg.style.opacity = '0'
  svg.id = 'svg-' + generateRandomId()

  // Add children
  if (children) {
    children.forEach((child) => svg.appendChild(child))
  }

  return svg
}

function colorToString(color: Color) {
  if (color.type === 'hex') {
    return color.color
  } else if (color.type === 'rgb') {
    return 'rgb(' + color.color.join(',') + ')'
  } else if (color.type === 'rgba') {
    return 'rgba(' + color.color.join(',') + ')'
  } else {
    return `hsl(${color.color[0]}, ${color.color[1]}%, ${color.color[2]}%)`
  }
}

function createSVGElement(
  type: string,
  fillColor: Color,
  strokeColor: Color,
  strokeWidth: number,
  attrs
) {
  const elem = document.createElementNS(svgNS, type)
  elem.setAttribute('stroke', colorToString(strokeColor))
  elem.setAttribute('stroke-width', strokeWidth.toString())
  elem.setAttribute('fill', colorToString(fillColor))

  for (const key in attrs) {
    elem.setAttribute(key, attrs[key])
  }
  return elem
}
export function line(
  x1: number,
  y1: number,
  x2: number,
  y2: number,

  strokeColor: Color,
  strokeWidth: number,
  fillColor: Color
) {
  const rect = createSVGElement('line', fillColor, strokeColor, strokeWidth, {
    x1: x1.toString(),
    y1: y1.toString(),
    x2: x2.toString(),
    y2: y2.toString(),
  })

  return createSVG([rect])
}

export function rect(
  x: number,
  y: number,
  width: number,
  height: number,
  strokeColor: Color,
  strokeWidth: number,
  fillColor: Color
) {
  const rect = createSVGElement('rect', fillColor, strokeColor, strokeWidth, {
    x: x.toString(),
    y: y.toString(),
    width: width.toString(),
    height: height.toString(),
  })

  return createSVG([rect])
}

export function circle(
  cx: number,
  cy: number,
  radius: number,
  strokeColor: Color,
  strokeWidth: number,
  fillColor: Color
) {
  const circle = createSVGElement(
    'circle',
    fillColor,
    strokeColor,
    strokeWidth,
    {
      cx: cx.toString(),
      cy: cy.toString(),
      r: radius.toString(),
    }
  )

  return createSVG([circle])
}

export function ellipse(
  cx: number,
  cy: number,
  rx: number,
  ry: number,
  strokeColor: Color,
  strokeWidth: number,
  fillColor: Color
) {
  const ellipse = createSVGElement(
    'ellipse',
    fillColor,
    strokeColor,
    strokeWidth,
    {
      cx: cx.toString(),
      cy: cy.toString(),
      rx: rx.toString(),
      ry: ry.toString(),
    }
  )

  return createSVG([ellipse])
}

export function triangle(
  x1: number,
  y1: number,
  x2: number,
  y2: number,
  x3: number,
  y3: number,
  strokeColor: Color,
  strokeWidth: number,
  fillColor: Color
) {
  const polygon = createSVGElement(
    'polygon',
    fillColor,
    strokeColor,
    strokeWidth,
    {
      points: `${x1},${y1} ${x2},${y2} ${x3},${y3}`,
    }
  )
  return createSVG([polygon])
}

function generateRandomId(): string {
  return Math.random().toString(36).slice(2, 11)
}
