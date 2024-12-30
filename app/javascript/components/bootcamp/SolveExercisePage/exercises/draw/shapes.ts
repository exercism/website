export function rect(
  x: string,
  y: string,
  width: string,
  height: string,
  penColor: string,
  backgroundColor: string
) {
  const rect = document.createElement('div')
  rect.id = `rect-${generateRandomId()}`
  rect.style.border = `1px solid ${penColor}`
  rect.style.backgroundColor = backgroundColor
  rect.style.width = width
  rect.style.height = height
  rect.style.position = 'absolute'

  return rect
}

export function circle(
  x: string,
  y: string,
  radius: string,
  penColor: string,
  backgroundColor: string
) {
  const circle = document.createElement('div')
  circle.id = `circle-${generateRandomId()}`
  circle.style.border = `1px solid ${penColor}`
  circle.style.backgroundColor = backgroundColor
  circle.style.width = `calc(2*${radius})`
  circle.style.height = `calc(2*${radius})`
  circle.style.position = 'absolute'
  circle.style.borderRadius = '50%'

  return circle
}

export function ellipse(x: number, y: number, width: number, height: number) {
  /*const ellipse = document.createElement("div");
  ellipse.id = "ellipse-" + generateRandomId();
  ellipse.style.border = "1px solid black";
  ellipse.style.width = `${width}px`;
  ellipse.style.height = `${height}px`;
  ellipse.style.position = "absolute";
  ellipse.style.left = `${x - width / 2}px`;
  ellipse.style.top = `${y - height / 2}px`;
  ellipse.style.borderRadius = "50%";
  ellipse.style.opacity = "1";

  return ellipse;*/
}

export function triangle(
  x1: string,
  y1: string,
  x2: string,
  y2: string,
  x3: string,
  y3: string,
  penColor: string,
  backgroundColor: string
) {
  const [x1a, x2a, x3a] = [parseFloat(x1), parseFloat(x2), parseFloat(x3)]
  const [y1a, y2a, y3a] = [parseFloat(y1), parseFloat(y2), parseFloat(y3)]

  const svgNS = 'http://www.w3.org/2000/svg'
  const triangle = document.createElementNS(svgNS, 'svg')

  // Set the width and height of the div
  triangle.style.position = 'absolute'
  triangle.style.inset = '0'
  triangle.style.backgroundColor = 'transparent'

  // Create the SVG element
  triangle.setAttribute('viewBox', `0 0 100 100`) // Set viewBox for relative coordinates
  triangle.setAttribute('overflow', 'visible')

  // Create the triangle polygon
  const polygon = document.createElementNS(svgNS, 'polygon')
  polygon.setAttribute('points', `${x1a},${y1a} ${x2a},${y2a} ${x3a},${y3a}`)
  polygon.setAttribute('fill', backgroundColor)
  polygon.setAttribute('stroke', penColor)
  polygon.setAttribute('stroke-width', '1')

  // Append the triangle to the SVG
  triangle.appendChild(polygon)

  // Create the canvas
  // const canvas = document.createElement("canvas");
  // const canvasWidth = (widthPercentage) + padding ; // Add padding
  // const canvasHeight = (heightPercentage) + padding ; // Add padding

  // canvas.setAttribute("width", maxXRel + 5)
  // canvas.setAttribute("height", maxYRel + 5)
  // canvas.style.width = "100%";
  // canvas.style.height = "100%";
  // canvas.style.position = "absolute";

  // triangle.appendChild(canvas);

  // Draw the triangle on the canvas
  // const context = canvas.getContext("2d");
  // if (!context) {
  //   console.error("Failed to get 2D context");
  //   return;
  // }

  // context.beginPath();
  // context.moveTo(x1Rel + padding, y1Rel + padding);
  // context.lineTo(x2Rel + padding, y2Rel + padding);
  // context.lineTo(x3Rel + padding, y3Rel + padding);
  // context.closePath();

  // // Style the triangle
  // context.lineWidth = 2; // Adjusted line width
  // context.strokeStyle = '#666666';
  // context.stroke();

  // context.fillStyle = "#FFCC00";
  // context.fill();
  return triangle
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
