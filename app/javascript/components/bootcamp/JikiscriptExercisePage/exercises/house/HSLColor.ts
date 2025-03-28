import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import HouseExercise from './HouseExercise'

export type HSLColorInstance = Jiki.Instance & {}

function fn(this: HouseExercise) {
  const HSLColor = new Jiki.Class('HSLColor')
  HSLColor.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    hue: Jiki.JikiObject,
    saturation: Jiki.JikiObject,
    luminosity: Jiki.JikiObject
  ) {
    if (
      !(hue instanceof Jiki.Number) ||
      !(saturation instanceof Jiki.Number) ||
      !(luminosity instanceof Jiki.Number)
    ) {
      return executionCtx.logicError('All parameters must be numbers.')
    }
    object.setField('hue', hue)
    object.setField('saturation', saturation)
    object.setField('luminosity', luminosity)
  })
  HSLColor.addGetter('hue', 'public')
  HSLColor.addGetter('saturation', 'public')
  HSLColor.addGetter('luminosity', 'public')

  return HSLColor
}

export function buildHSLColor(binder: any) {
  return fn.bind(binder)()
}
