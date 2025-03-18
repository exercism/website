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
      new Jiki.Number(100 - (ground.getField('height') as Jiki.Number).value),
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
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    height: Jiki.JikiObject,
    z_index: Jiki.JikiObject
  ) {
    if (!(height instanceof Jiki.Number) || !(z_index instanceof Jiki.Number)) {
      executionCtx.logicError(
        'Ground constructor requires height and z_index to be numbers'
      )
    }
    object.setField('height', height)
    object.setField('z_index', z_index)
    drawGround(executionCtx, object)
  })
  Ground.addGetter('height', 'public')
  Ground.addSetter(
    'brightness',
    'public',
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
