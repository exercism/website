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

  const changeGroundBrightness = (
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
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    left: Jiki.Number,
    top: Jiki.Number,
    width: Jiki.Number,
    height: Jiki.Number,
    z_index: Jiki.Number
  ) {
    this.fields['left'] = left
    this.fields['top'] = top
    this.fields['width'] = width
    this.fields['height'] = height
    this.fields['z_index'] = z_index
    drawFrame(executionCtx, this)
  })
  Frame.addSetter(
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
      changeGroundBrightness(executionCtx, this)
    }
  )

  return Frame
}

export function buildFrame(binder: any) {
  return fn.bind(binder)()
}
