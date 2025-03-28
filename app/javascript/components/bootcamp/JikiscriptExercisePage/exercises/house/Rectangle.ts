import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { storeShape, changeBrightness } from './Component'
import HouseExercise from './HouseExercise'
import { guardValidHex } from './helpers'
import { buildHSLColor, type HSLColorInstance } from './HSLColor'

function fn(this: HouseExercise) {
  const exercise = this
  const drawRectangle = (
    executionCtx: ExecutionContext,
    rectangle: Jiki.Instance
  ) => {
    const hsl = rectangle.getField('hsl') as HSLColorInstance
    this.fillColorHSL(
      executionCtx,
      hsl.getField('hue') as Jiki.Number,
      hsl.getField('saturation') as Jiki.Number,
      hsl.getField('luminosity') as Jiki.Number
    )
    this.rectangle(
      executionCtx,
      rectangle.getField('left') as Jiki.Number,
      rectangle.getField('top') as Jiki.Number,
      rectangle.getField('width') as Jiki.Number,
      rectangle.getField('height') as Jiki.Number
    )
    storeShape(this, rectangle)
  }

  const changeRectangleBrightness = (
    executionCtx: ExecutionContext,
    rectangle: Jiki.Instance
  ) => {
    changeBrightness(executionCtx, this, rectangle)
    this.events.push(
      `rectangle:brightness:${rectangle.getUnwrappedField('brightness')}`
    )
  }

  const changeRectangleHue = (
    executionCtx: ExecutionContext,
    rectangle: Jiki.Instance
  ) => {
    const shape = rectangle['shape']
    const hsl = rectangle.getField('hsl') as HSLColorInstance
    this.addAnimation({
      targets: `#${this.view.id} #${shape.element.id} rect`,
      duration: 1,
      transformations: {
        fill: `hsl(${hsl.getUnwrappedField('hue')}, ${hsl.getUnwrappedField(
          'saturation'
        )}%, ${hsl.getUnwrappedField('luminosity')}%))`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)

    this.events.push(`sky:hue:${hsl.getUnwrappedField('hue')}`)
  }

  const Rectangle = new Jiki.Class('Rectangle')
  Rectangle.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    left: Jiki.JikiObject,
    top: Jiki.JikiObject,
    width: Jiki.JikiObject,
    height: Jiki.JikiObject,
    hslColor: Jiki.JikiObject,
    z_index: Jiki.JikiObject
  ) {
    if (!(left instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Left must be a number.')
    }
    if (!(top instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Top must be a number.')
    }
    if (!(width instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Width must be a number.')
    }
    if (!(height instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Height must be a number.')
    }
    if (!(z_index instanceof Jiki.Number)) {
      return executionCtx.logicError('Ooops! Z-index must be a number.')
    }

    object.setField('left', left)
    object.setField('top', top)
    object.setField('width', width)
    object.setField('height', height)
    object.setField('hsl', hslColor)
    object.setField('brightness', new Jiki.Number(100))
    object.setField('z_index', z_index)
    drawRectangle(executionCtx, object)
  })
  Rectangle.addGetter('brightness', 'public')
  Rectangle.addGetter('hsl', 'public')
  Rectangle.addSetter(
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
      changeRectangleBrightness(executionCtx, object)
    }
  )
  Rectangle.addSetter(
    'hsl',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      hsl: Jiki.JikiObject
    ) {
      if (
        !(
          hsl instanceof Jiki.Instance ||
          (hsl as Jiki.Instance).jikiClass.name != 'HSLColor'
        )
      ) {
        return executionCtx.logicError('Ooops! HSL must be an HSL Object.')
      }
      const hslString = `${hsl.getUnwrappedField(
        'hue'
      )}:${hsl.getUnwrappedField('saturation')}:${hsl.getUnwrappedField(
        'luminosity'
      )}`
      exercise.events.push(`rectangle:hsl:${hslString}`)
      object.setField('hsl', hsl)
      changeRectangleHue(executionCtx, object)
    }
  )

  return Rectangle
}

export function buildRectangle(binder: any) {
  return fn.bind(binder)()
}
