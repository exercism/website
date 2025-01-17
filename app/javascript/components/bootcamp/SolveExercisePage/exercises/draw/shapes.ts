import { FillColor } from './DrawExercise'

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

function createSVGElement(
  type: string,
  backgroundColor: FillColor,
  penColor,
  attrs
) {
  const elem = document.createElementNS(svgNS, type)
  elem.setAttribute('stroke', penColor)
  elem.setAttribute('stroke-width', '0')

  if (backgroundColor.type === 'hex') {
    elem.setAttribute('fill', backgroundColor.color)
  } else if (backgroundColor.type === 'rgb') {
    elem.setAttribute('fill', 'rgb(' + backgroundColor.color.join(',') + ')')
  } else {
    elem.setAttribute(
      'fill',
      `hsl(${backgroundColor.color[0]}, ${backgroundColor.color[1]}%, ${backgroundColor.color[2]}%)`
    )
  }

  for (const key in attrs) {
    elem.setAttribute(key, attrs[key])
  }
  return elem
}

export function rect(
  x: number,
  y: number,
  width: number,
  height: number,
  penColor: string,
  backgroundColor: FillColor
) {
  const rect = createSVGElement('rect', backgroundColor, penColor, {
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
  penColor: string,
  backgroundColor: FillColor
) {
  const circle = createSVGElement('circle', backgroundColor, penColor, {
    cx: cx.toString(),
    cy: cy.toString(),
    r: radius.toString(),
  })

  return createSVG([circle])
}

export function ellipse(
  cx: number,
  cy: number,
  rx: number,
  ry: number,
  penColor: string,
  backgroundColor: FillColor
) {
  const ellipse = createSVGElement('ellipse', backgroundColor, penColor, {
    cx: cx.toString(),
    cy: cy.toString(),
    rx: rx.toString(),
    ry: ry.toString(),
  })

  return createSVG([ellipse])
}

export function triangle(
  x1: number,
  y1: number,
  x2: number,
  y2: number,
  x3: number,
  y3: number,
  penColor: string,
  backgroundColor: FillColor
) {
  const polygon = createSVGElement('polygon', backgroundColor, penColor, {
    points: `${x1},${y1} ${x2},${y2} ${x3},${y3}`,
  })
  return createSVG([polygon])
}

export function hexagon(x: number, y: number, size: number) {
  const hexagon = document.createElement('div')
  hexagon.id = 'hexagon-' + generateRandomId()
  hexagon.style.width = `${size}px`
  hexagon.style.height = `${(size * Math.sqrt(3)) / 2}px`
  hexagon.style.position = 'absolute'
  hexagon.style.left = `${x - size / 2}px`
  hexagon.style.top = `${y - (size * Math.sqrt(3)) / 4}px`
  hexagon.style.backgroundColor = 'black'
  hexagon.style.clipPath =
    'polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%)'
  hexagon.style.opacity = '1'

  return hexagon
}

/**
 * Draws a polygon where x and y are the top left corner of the bounding box
 */
export function polygon(x: number, y: number, radius: number, sides: number) {
  if (sides < 3) throw new Error('A polygon must have at least 3 sides')

  const polygonDiv = document.createElement('div')
  polygonDiv.id = 'polygon-' + generateRandomId()
  polygonDiv.style.position = 'absolute'
  polygonDiv.style.opacity = '0'

  const svgNamespace = 'http://www.w3.org/2000/svg'
  const svg = document.createElementNS(svgNamespace, 'svg')

  const size = radius * 2
  svg.setAttribute('width', `${size}px`)
  svg.setAttribute('height', `${size}px`)
  svg.setAttribute('viewBox', `0 0 ${size} ${size}`)

  const polygonShape = document.createElementNS(svgNamespace, 'polygon')

  const points = []
  for (let i = 0; i < sides; i++) {
    const angle = (i * 2 * Math.PI) / sides
    const pointX = radius + radius * Math.cos(angle)
    const pointY = radius + radius * Math.sin(angle)
    points.push(`${pointX},${pointY}`)
  }

  polygonShape.setAttribute('points', points.join(' '))
  polygonShape.setAttribute('fill', 'none')
  polygonShape.setAttribute('stroke', 'black')

  svg.appendChild(polygonShape)
  polygonDiv.appendChild(svg)

  polygonDiv.style.left = `${x}px`
  polygonDiv.style.top = `${y}px`

  return polygonDiv
}

function generateRandomId(): string {
  return Math.random().toString(36).slice(2, 11)
}

export function square(x: number, y: number, side: number) {
  const rect = document.createElement('div')
  rect.id = 'square-' + generateRandomId
  rect.style.border = '1px solid black'
  rect.style.width = `${side}px`
  rect.style.height = `${side}px`
  rect.style.position = 'absolute'
  rect.style.left = `${x}px`
  rect.style.top = `${y}px`
  rect.style.opacity = '1'

  return rect
}
