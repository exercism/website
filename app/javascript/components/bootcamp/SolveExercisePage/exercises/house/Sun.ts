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
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    cx: Jiki.Number,
    cy: Jiki.Number,
    radius: Jiki.Number,
    z_index: Jiki.Number
  ) {
    this.fields['cx'] = cx
    this.fields['cy'] = cy
    this.fields['radius'] = radius
    this.fields['z_index'] = z_index
    drawSun(executionCtx, this)
  })
  Sun.addGetter('cx')
  Sun.addGetter('cy')

  Sun.addSetter(
    'cx',
    function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      cx: Jiki.JikiObject
    ) {
      if (!(cx instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Cx must be a number.')
      }
      this.fields['cx'] = cx

      drawSun(executionCtx, this)
    }
  )
  Sun.addSetter(
    'cy',
    function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      cy: Jiki.JikiObject
    ) {
      if (!(cy instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Cy must be a number.')
      }
      this.fields['cy'] = cy

      drawSun(executionCtx, this)
    }
  )
  return Sun
}

export function buildSun(binder: any) {
  return fn.bind(binder)()
}
