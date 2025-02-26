import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { storeShape, changeBrightness } from './Component'

function fn(this: any) {
  const drawSky = (executionCtx: ExecutionContext, sky: Jiki.Instance) => {
    this.fillColorHSL(
      executionCtx,
      sky.getField('hue'),
      new Jiki.Number(70),
      new Jiki.Number(60)
    )
    this.rectangle(
      executionCtx,
      new Jiki.Number(0),
      new Jiki.Number(0),
      new Jiki.Number(100),
      new Jiki.Number(100)
    )
    storeShape(this, sky)
  }

  const changeSkyBrightness = (
    executionCtx: ExecutionContext,
    sky: Jiki.Instance
  ) => {
    changeBrightness(executionCtx, this, sky)
    this.events.push(`sky:brightness:${sky.getUnwrappedField('brightness')}`)
  }

  const changeSkyHue = (executionCtx: ExecutionContext, sky: Jiki.Instance) => {
    const shape = sky['shape']
    this.addAnimation({
      targets: `#${this.view.id} #${shape.element.id} rect`,
      duration: 1,
      transformations: {
        fill: `hsl(${sky.getUnwrappedField('hue')}, 70%, 60%))`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)

    this.events.push(`sky:hue:${sky.getUnwrappedField('hue')}`)
  }

  const Sky = new Jiki.Class('Sky')
  Sky.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    z_index: Jiki.Number
  ) {
    this.fields['z_index'] = z_index
    this.fields['hue'] = new Jiki.Number(190)
    drawSky(executionCtx, this)
  })
  Sky.addSetter(
    'brightness',
    function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      brightness: Jiki.Number
    ) {
      if (!(brightness instanceof Jiki.Number)) {
        executionCtx.logicError('Ooops! Brightness must be a number.')
      }
      if (brightness.value < 0 || brightness.value > 100) {
        executionCtx.logicError('Brightness must be between 0 and 100')
      }
      this.fields['brightness'] = brightness
      changeSkyBrightness(executionCtx, this)
    }
  )
  Sky.addGetter('hue')
  Sky.addSetter(
    'hue',
    function (
      this: Jiki.Instance,
      executionCtx: ExecutionContext,
      hue: Jiki.Number
    ) {
      if (!(hue instanceof Jiki.Number)) {
        executionCtx.logicError('Ooops! Hue must be a number.')
      }
      if (hue.value < 0) {
        executionCtx.logicError("Hue can't go below 0!")
      }
      if (hue.value > 310) {
        executionCtx.logicError("The sky can't go more red than 310!")
      }
      this.fields['hue'] = hue
      changeSkyHue(executionCtx, this)
    }
  )

  return Sky
}

export function buildSky(binder: any) {
  return fn.bind(binder)()
}
