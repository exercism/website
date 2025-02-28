import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { storeShape, changeBrightness } from './Component'
import HouseExercise from './HouseExercise'

function fn(this: HouseExercise) {
  const drawRoof = (executionCtx: ExecutionContext, roof: Jiki.Instance) => {
    this.fillColorHex(executionCtx, new Jiki.String('#8b4513'))
    this.triangle(
      executionCtx,
      roof.getField('left') as Jiki.Number,
      roof.getField('bottom') as Jiki.Number,
      roof.getField('center') as Jiki.Number,
      roof.getField('top') as Jiki.Number,
      roof.getField('right') as Jiki.Number,
      roof.getField('bottom') as Jiki.Number
    )
    storeShape(this, roof)
  }

  const changeRoofBrightness = (
    executionCtx: ExecutionContext,
    roof: Jiki.Instance
  ) => {
    changeBrightness(executionCtx, this, roof)
    this.events.push(`roof:brightness:${roof.getUnwrappedField('brightness')}`)
  }

  const Roof = new Jiki.Class('Roof')
  Roof.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    center: Jiki.Number,
    top: Jiki.Number,
    width: Jiki.Number,
    height: Jiki.Number,
    z_index: Jiki.Number
  ) {
    this.fields['center'] = center
    this.fields['top'] = top
    this.fields['height'] = height
    this.fields['width'] = width
    this.fields['left'] = new Jiki.Number(center.value - width.value / 2)
    this.fields['right'] = new Jiki.Number(center.value + width.value / 2)
    this.fields['bottom'] = new Jiki.Number(top.value + height.value)
    this.fields['z_index'] = z_index
    drawRoof(executionCtx, this)
  })
  Roof.addSetter(
    'brightness',
    function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      brightness: Jiki.JikiObject
    ) {
      if (!(brightness instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Brightness must be a number.')
      }
      if (brightness.value < 0 || brightness.value > 100) {
        return executionCtx.logicError('Brightness must be between 0 and 100')
      }
      this.fields['brightness'] = brightness
      changeRoofBrightness(executionCtx, this)
    }
  )

  return Roof
}

export function buildRoof(binder: any) {
  return fn.bind(binder)()
}
