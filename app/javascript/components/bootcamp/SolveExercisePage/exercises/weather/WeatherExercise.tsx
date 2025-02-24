import React from 'react'
import DrawExercise from '../draw'
import { Circle, Rectangle, Triangle, Ellipse } from '../draw/shapes'

export default class WeatherExercise extends DrawExercise {
  public constructor() {
    super('weather')
  }

  public showReportBackground() {
    const report = document.createElement('div')
    report.classList.add('weather-report')
    this.view.prepend(report)

    const top = document.createElement('div')
    top.classList.add('top')
    report.appendChild(top)

    const mainIcon = document.createElement('div')
    mainIcon.classList.add('main-icon')
    top.appendChild(mainIcon)

    const middle = document.createElement('div')
    middle.classList.add('middle')
    report.appendChild(middle)

    const ml = document.createElement('div')
    ml.innerHTML = '7am'
    middle.appendChild(ml)

    const mm = document.createElement('div')
    mm.innerHTML = '8am'
    middle.appendChild(mm)

    const mr = document.createElement('div')
    mr.innerHTML = '9am'
    middle.appendChild(mr)

    const bottom = document.createElement('div')
    bottom.classList.add('bottom')
    report.appendChild(bottom)

    for (let i = 0; i < 3; i++) {
      const elem = document.createElement('div')
      bottom.appendChild(elem)
    }
  }

  public doEnd(_) {
    console.log(
      this.shapes
        .map((shape) => {
          if (shape instanceof Circle) {
            return (
              'getCircleAt(' +
              shape.cx +
              ', ' +
              shape.cy +
              ', ' +
              shape.radius +
              ')'
            )
          }
          if (shape instanceof Rectangle) {
            return (
              'getRectangleAt(' +
              shape.x +
              ', ' +
              shape.y +
              ', ' +
              shape.width +
              ', ' +
              shape.height +
              ')'
            )
          }
          if (shape instanceof Triangle) {
            return (
              'getTriangleAt(' +
              shape.x1 +
              ', ' +
              shape.y1 +
              ', ' +
              shape.x2 +
              ', ' +
              shape.y2 +
              ', ' +
              shape.x3 +
              ', ' +
              shape.y3 +
              ')'
            )
          }
          if (shape instanceof Ellipse) {
            return (
              'getEllipseAt(' +
              shape.x +
              ', ' +
              shape.y +
              ', ' +
              shape.rx +
              ', ' +
              shape.ry +
              ')'
            )
          }
          return ''
        })
        .join('\n')
    )
  }

  // TODO: How do I get just the ones I want out of DrawExercise
  // (circle, fillColorHex, fillColorRGB, fillColorHSL)
  // and then add the new ones to this?
  public availableFunctions = [
    { name: 'doEnd', func: this.doEnd.bind(this), description: '' },
    {
      name: 'clear',
      func: this.clear.bind(this),
      description: 'Clears the canvas.',
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
      name: 'fill_color_hex',
      func: this.fillColorHex.bind(this),
      description: 'Changes the fill color using a hex string',
    },
    {
      name: 'fill_color_rgb',
      func: this.fillColorRGB.bind(this),
      description: 'Changes the fill color using red, green and blue values',
    },
    {
      name: 'fill_color_hsl',
      func: this.fillColorHSL.bind(this),
      description:
        'Changes the fill color using hue, saturation and lumisity values',
    },
  ]
}
