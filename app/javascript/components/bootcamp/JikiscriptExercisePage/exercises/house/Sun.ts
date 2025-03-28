import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import HouseExercise from './HouseExercise'
import { storeShape } from './Component'

function fn(this: HouseExercise) {
  const drawSun = (executionCtx: ExecutionContext, sun: Jiki.Instance) => {
    if (sun['shape']) {
      this.animateShapeOutOfView(executionCtx, sun['shape'].element)
    }

    this.fillColorHex(executionCtx, new Jiki.String('yellow'))
    this.circle(
      executionCtx,
      sun.getField('cx') as Jiki.Number,
      sun.getField('cy') as Jiki.Number,
      sun.getField('radius') as Jiki.Number
    )
    storeShape(this, sun)

    this.events.push(
      `sun:position:${sun.getUnwrappedField('cx')},${sun.getUnwrappedField(
        'cy'
      )}`
    )
  }

  const Sun = new Jiki.Class('Sun')
  Sun.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    cx: Jiki.JikiObject,
    cy: Jiki.JikiObject,
    radius: Jiki.JikiObject,
    z_index: Jiki.JikiObject
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
    if (!(z_index instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Z-index must be a number.')
    }

    object.setField('cx', cx)
    object.setField('cy', cy)
    object.setField('radius', radius)
    object.setField('z_index', z_index)
    drawSun(executionCtx, object)
  })
  Sun.addGetter('cx', 'public')
  Sun.addGetter('cy', 'public')

  Sun.addSetter(
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

      drawSun(executionCtx, object)
    }
  )
  Sun.addSetter(
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

      drawSun(executionCtx, object)
    }
  )
  return Sun
}

export function buildSun(binder: any) {
  return fn.bind(binder)()
}
