import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import { storeShape, changeBrightness } from './Component'
import HouseExercise from './HouseExercise'
import { guardValidHex } from './helpers'

function fn(this: HouseExercise) {
  const drawTriangle = (
    executionCtx: ExecutionContext,
    triangle: Jiki.Instance
  ) => {
    this.fillColorHex(
      executionCtx,
      triangle.getField('fillColorHex') as Jiki.String
    )
    this.triangle(
      executionCtx,
      triangle.getField('x1') as Jiki.Number,
      triangle.getField('y1') as Jiki.Number,
      triangle.getField('x2') as Jiki.Number,
      triangle.getField('y2') as Jiki.Number,
      triangle.getField('x3') as Jiki.Number,
      triangle.getField('y3') as Jiki.Number
    )
    storeShape(this, triangle)
  }

  const changeTriangleBrightness = (
    executionCtx: ExecutionContext,
    triangle: Jiki.Instance
  ) => {
    changeBrightness(executionCtx, this, triangle)
    this.events.push(
      `triangle:brightness:${triangle.getUnwrappedField('brightness')}`
    )
  }
  const Triangle = new Jiki.Class('Triangle')
  Triangle.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    x1: Jiki.JikiObject,
    y1: Jiki.JikiObject,
    x2: Jiki.JikiObject,
    y2: Jiki.JikiObject,
    x3: Jiki.JikiObject,
    y3: Jiki.JikiObject,
    fillColorHex: Jiki.JikiObject,
    z_index: Jiki.JikiObject
  ) {
    if (
      !(x1 instanceof Jiki.Number) ||
      !(y1 instanceof Jiki.Number) ||
      !(x2 instanceof Jiki.Number) ||
      !(y2 instanceof Jiki.Number) ||
      !(x3 instanceof Jiki.Number) ||
      !(y3 instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All parameters must be numbers.')
    }
    guardValidHex(executionCtx, fillColorHex)

    object.setField('x1', x1)
    object.setField('y1', y1)
    object.setField('x2', x2)
    object.setField('y2', y2)
    object.setField('x3', x3)
    object.setField('y3', y3)
    object.setField('fillColorHex', fillColorHex)
    object.setField('z_index', z_index)
    drawTriangle(executionCtx, object)
  })
  Triangle.addSetter(
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
      changeTriangleBrightness(executionCtx, object)
    }
  )

  return Triangle
}

export function buildTriangle(binder: any) {
  return fn.bind(binder)()
}
