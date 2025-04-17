import { ExecutionContext } from '@/interpreter/executor'
import HouseExercise from './HouseExercise'
import * as Jiki from '@/interpreter/jikiObjects'

export function storeShape(exercise: HouseExercise, instance: Jiki.Instance) {
  ;(function (this: HouseExercise) {
    const shape = this.shapes[this.shapes.length - 1]
    instance['shape'] = shape
    shape.element.style.filter = 'brightness(100%)'
    shape.element.style.zIndex = (
      instance.getField('z_index') as Jiki.Number
    ).value.toString()
  }).apply(exercise)
}

export function changeBrightness(
  executionCtx: ExecutionContext,
  exercise: HouseExercise,
  object: Jiki.Instance
) {
  ;(function (this: HouseExercise) {
    const shape = object['shape']
    this.addAnimation({
      targets: `#${this.view.id} #${shape.element.id}`,
      duration: 1,
      transformations: {
        filter: `brightness(${object.getUnwrappedField('brightness')}%)`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }).apply(exercise)
}
