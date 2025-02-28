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
    drawWindow(executionCtx, this)
  })
  Window.addSetter(
    'lights',
    function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      lights: Jiki.Boolean
    ) {
      if (!(lights instanceof Jiki.Boolean)) {
        executionCtx.logicError('Ooops! Lights must be a boolean.')
      }
      if (lights && lights.value == this.getUnwrappedField('lights')) {
        executionCtx.logicError('Ooops! The lights are turned already on.')
      }

      this.fields['lights'] = lights
      drawWindow(executionCtx, this)
      rememberLightsToggle(executionCtx, this)
    }
  )
  return Window
}

export function buildWindow(binder: any) {
  return fn.bind(binder)()
}
