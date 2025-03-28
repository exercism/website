import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { storeShape, changeBrightness } from './Component'
import HouseExercise from './HouseExercise'

function fn(this: HouseExercise) {
  const drawFrame = (executionCtx: ExecutionContext, frame: Jiki.Instance) => {
    this.fillColorHex(executionCtx, new Jiki.String('#f0985b'))
    this.rectangle(
      executionCtx,
      frame.getField('left') as Jiki.Number,
      frame.getField('top') as Jiki.Number,
      frame.getField('width') as Jiki.Number,
      frame.getField('height') as Jiki.Number
    )
    storeShape(this, frame)
  }

  const changeFrameBrightness = (
    executionCtx: ExecutionContext,
    frame: Jiki.Instance
  ) => {
    changeBrightness(executionCtx, this, frame)
    this.events.push(
      `frame:brightness:${frame.getUnwrappedField('brightness')}`
    )
  }

  const Frame = new Jiki.Class('Frame')
  Frame.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    left: Jiki.JikiObject,
    top: Jiki.JikiObject,
    width: Jiki.JikiObject,
    height: Jiki.JikiObject,
    z_index: Jiki.JikiObject
  ) {
    if (
      !(left instanceof Jiki.Number) ||
      !(top instanceof Jiki.Number) ||
      !(width instanceof Jiki.Number) ||
      !(height instanceof Jiki.Number) ||
      !(z_index instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All parameters must be numbers.')
    }
    object.setField('left', left)
    object.setField('top', top)
    object.setField('width', width)
    object.setField('height', height)
    object.setField('z_index', z_index)
    drawFrame(executionCtx, object)
  })
  Frame.addGetter('left', 'public')
  Frame.addGetter('top', 'public')
  Frame.addSetter(
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
      changeFrameBrightness(executionCtx, object)
    }
  )

  return Frame
}

export function buildFrame(binder: any) {
  return fn.bind(binder)()
}
