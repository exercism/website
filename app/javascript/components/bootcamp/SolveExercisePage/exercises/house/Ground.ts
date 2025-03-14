import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { changeBrightness, storeShape } from './Component'

function fn(this: any) {
  const drawGround = (
    executionCtx: ExecutionContext,
    ground: Jiki.Instance
  ) => {
    this.fillColorHex(executionCtx, new Jiki.String('#3cb372'))
    this.rectangle(
      executionCtx,
      new Jiki.Number(0),
      new Jiki.Number(100 - ground.getField('height').value),
      new Jiki.Number(100),
      ground.getField('height') as Jiki.Number
    )
    storeShape(this, ground)
  }

  const changeGroundBrightness = (
    executionCtx: ExecutionContext,
    ground: Jiki.Instance
  ) => {
    changeBrightness(executionCtx, this, ground)
    this.events.push(
      `ground:brightness:${ground.getUnwrappedField('brightness')}`
    )
  }

  const Ground = new Jiki.Class('Ground')
  Ground.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    height: Jiki.Number,
    z_index: Jiki.Number
  ) {
    if (height == undefined || z_index == undefined) {
      executionCtx.logicError('Ground constructor requires height and z_index')
    }
    this.fields['height'] = height
    this.fields['z_index'] = z_index
    drawGround(executionCtx, this)
  })
  Ground.addSetter(
    'brightness',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      brightness: Jiki.JikiObject
    ) {
      if (!(brightness instanceof Jiki.Number)) {
        return executionCtx.logicError('Ooops! Brightness must be a number.')
      }
      if (brightness.value < 0 || brightness.value > 100) {
        executionCtx.logicError('Brightness must be between 0 and 100')
      }
      object.setField('brightness', brightness)
      changeGroundBrightness(executionCtx, object)
    }
  )

  return Ground
}

export function buildGround(binder: any) {
  return fn.bind(binder)()
}
