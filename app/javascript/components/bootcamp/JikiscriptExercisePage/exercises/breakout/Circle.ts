import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import BreakoutExercise from './BreakoutExercise'
import { guardValidHex } from '../house/helpers'

export type CircleInstance = Jiki.Instance & {}

function fn(this: BreakoutExercise) {
  const exercise = this

  const drawCircle = (
    executionCtx: ExecutionContext,
    circle: Jiki.Instance
  ) => {
    const div = document.createElement('div')
    div.classList.add('circle')
    div.id = `circle-${circle.objectId}`
    div.style.left = `${circle.getUnwrappedField('cx')}%`
    div.style.top = `${circle.getUnwrappedField('cy')}%`
    div.style.width = `${circle.getUnwrappedField('radius') * 2}%`
    div.style.height = `${circle.getUnwrappedField('radius') * 2}%`
    div.style.backgroundColor = circle.getUnwrappedField('fill_color_hex')
    div.style.opacity = '0'
    this.container.appendChild(div)
    this.animateIntoView(
      executionCtx,
      `#${this.view.id} #circle-${circle.objectId}`
    )

    exercise.circles.push(circle as CircleInstance)
  }
  const move = (executionCtx: ExecutionContext, circle: Jiki.Instance) => {
    this.addAnimation({
      targets: `#${this.view.id} #circle-${circle.objectId}`,
      duration: 1,
      transformations: {
        left: `${circle.getUnwrappedField('cx')}%`,
        top: `${circle.getUnwrappedField('cy')}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)

    exercise.circlePositions.push([
      circle.getUnwrappedField('cx'),
      circle.getUnwrappedField('cy'),
    ])
  }

  const Circle = new Jiki.Class('Circle')
  Circle.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    cx: Jiki.JikiObject,
    cy: Jiki.JikiObject,
    radius: Jiki.JikiObject,
    fillColorHex: Jiki.JikiObject
  ) {
    if (!(cx instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Cx must be a number.')
    }
    if (!(cy instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Cy must be a number.')
    }
    if (!(radius instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Radius must be a number.')
    }
    guardValidHex(executionCtx, fillColorHex)

    object.setField('cx', cx)
    object.setField('cy', cy)
    object.setField('radius', radius)
    object.setField('fill_color_hex', fillColorHex)
    drawCircle(executionCtx, object)
  })
  Circle.addGetter('cx', 'public')
  Circle.addGetter('cy', 'public')
  Circle.addGetter('radius', 'public')

  Circle.addSetter(
    'cx',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      cx: Jiki.JikiObject
    ) {
      if (!(cx instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Cx must be a number.')
      }
      object.setField('cx', cx)

      move(executionCtx, object)
    }
  )
  Circle.addSetter(
    'cy',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      cy: Jiki.JikiObject
    ) {
      if (!(cy instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Cy must be a number.')
      }
      object.setField('cy', cy)

      move(executionCtx, object)
    }
  )
  return Circle
}

export function buildCircle(binder: any) {
  return fn.bind(binder)()
}
