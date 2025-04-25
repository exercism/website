import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import BreakoutExercise from './BreakoutExercise'
import { guardValidHex } from '../house/helpers'

export type RoundedRectangleInstance = Jiki.Instance & {}
function fn(this: BreakoutExercise) {
  const exercise = this
  const drawRectangle = (
    executionCtx: ExecutionContext,
    rectangle: Jiki.Instance
  ) => {
    const div = document.createElement('div')
    div.classList.add('rectangle')
    div.id = `rect-${rectangle.objectId}`
    div.style.left = `${rectangle.getUnwrappedField('left')}%`
    div.style.top = `${rectangle.getUnwrappedField('top')}%`
    div.style.width = `${rectangle.getUnwrappedField('width')}%`
    div.style.height = `${rectangle.getUnwrappedField('height')}%`
    div.style.backgroundColor = rectangle.getUnwrappedField('fill_color_hex')
    div.style.borderRadius = `${rectangle.getUnwrappedField('corner_radius')}px`
    div.style.opacity = '0'
    this.container.appendChild(div)
    this.animateIntoView(
      executionCtx,
      `#${this.view.id} #rect-${rectangle.objectId}`
    )

    exercise.roundedRectangles.push(rectangle as RoundedRectangleInstance)
  }
  const move = (executionCtx: ExecutionContext, rectangle: Jiki.Instance) => {
    this.addAnimation({
      targets: `#${this.view.id} #rect-${rectangle.objectId}`,
      duration: 1,
      transformations: {
        left: `${rectangle.getUnwrappedField('left')}%`,
        top: `${rectangle.getUnwrappedField('top')}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }
  const changeOpacity = (
    executionCtx: ExecutionContext,
    rectangle: Jiki.Instance
  ) => {
    this.addAnimation({
      targets: `#${this.view.id} #rect-${rectangle.objectId}`,
      duration: 100,
      transformations: {
        opacity: `${rectangle.getUnwrappedField('opacity')}`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }

  const RoundedRectangle = new Jiki.Class('RoundedRectangle')
  RoundedRectangle.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    left: Jiki.JikiObject,
    top: Jiki.JikiObject,
    width: Jiki.JikiObject,
    height: Jiki.JikiObject,
    cornerRadius: Jiki.JikiObject,
    fillColorHex: Jiki.JikiObject
  ) {
    if (!(left instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Left must be a number.')
    }
    if (!(top instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Top must be a number.')
    }
    if (!(width instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Width must be a number.')
    }
    if (!(height instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Height must be a number.')
    }
    if (!(cornerRadius instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Corner radius must be a number.')
    }
    guardValidHex(executionCtx, fillColorHex)

    object.setField('left', left)
    object.setField('top', top)
    object.setField('width', width)
    object.setField('height', height)
    object.setField('corner_radius', cornerRadius)
    object.setField('fill_color_hex', fillColorHex)
    object.setField('opacity', new Jiki.Number(1))
    drawRectangle(executionCtx, object)
  })
  RoundedRectangle.addGetter('left', 'public')
  RoundedRectangle.addGetter('top', 'public')
  RoundedRectangle.addGetter('width', 'public')
  RoundedRectangle.addGetter('height', 'public')
  RoundedRectangle.addGetter('opacity', 'public')

  RoundedRectangle.addSetter(
    'left',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      left: Jiki.JikiObject
    ) {
      if (!(left instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Left must be a number.')
      }
      object.setField('left', left)

      move(executionCtx, object)
    }
  )
  RoundedRectangle.addSetter(
    'opacity',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      opacity: Jiki.JikiObject
    ) {
      if (!(opacity instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Opacity must be a number.')
      }
      object.setField('opacity', opacity)

      changeOpacity(executionCtx, object)
    }
  )
  return RoundedRectangle
}

export function buildRectangle(binder: any) {
  return fn.bind(binder)()
}
