import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { changeBrightness, storeShape } from './Component'

function fn(this: HouseExercise) {
  const drawWindow = (
    executionCtx: ExecutionContext,
    window: Jiki.Instance
  ) => {
    if (window['shape']) {
      this.animateShapeOutOfView(executionCtx, window['shape'].element)
    }

    const hex = new Jiki.String(
      window.getUnwrappedField('lights') ? '#FFFF00' : '#FFFFFF'
    )
    this.fillColorHex(executionCtx, hex)
    this.rectangle(
      executionCtx,
      window.getField('left') as Jiki.Number,
      window.getField('top') as Jiki.Number,
      window.getField('width') as Jiki.Number,
      window.getField('height') as Jiki.Number
    )
    storeShape(this, window)
  }

  const rememberLightsToggle = (
    executionCtx: ExecutionContext,
    window: Jiki.Instance
  ) => {
    if (window.getUnwrappedField('lights')) {
      this.events.push('window:lights:on')
    } else {
      this.events.push('window:lights:off')
    }
  }

  const Window = new Jiki.Class('Window')
  Window.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    left: Jiki.JikiObject,
    top: Jiki.JikiObject,
    width: Jiki.JikiObject,
    height: Jiki.JikiObject,
    z_index: Jiki.JikiObject
  ) {
    if (!(left instanceof Jiki.Number)) {
      return executionCtx.logicError('Left must be a number.')
    }
    if (!(top instanceof Jiki.Number)) {
      return executionCtx.logicError('Top must be a number.')
    }
    if (!(width instanceof Jiki.Number)) {
      return executionCtx.logicError('Width must be a number.')
    }
    if (!(height instanceof Jiki.Number)) {
      return executionCtx.logicError('Height must be a number.')
    }
    if (!(z_index instanceof Jiki.Number)) {
      return executionCtx.logicError('Z-index must be a number.')
    }

    object.setField('left', left)
    object.setField('top', top)
    object.setField('width', width)
    object.setField('height', height)
    object.setField('z_index', z_index)
    drawWindow(executionCtx, object)
  })
  Window.addSetter(
    'lights',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      lights: Jiki.JikiObject
    ) {
      if (!(lights instanceof Jiki.Boolean)) {
        return executionCtx.logicError('Ooops! Lights must be a boolean.')
      }
      if (lights && lights.value == object.getUnwrappedField('lights')) {
        executionCtx.logicError('Ooops! The lights are turned already on.')
      }

      object.setField('lights', lights)
      drawWindow(executionCtx, object)
      rememberLightsToggle(executionCtx, object)
    }
  )
  return Window
}

export function buildWindow(binder: any) {
  return fn.bind(binder)()
}
