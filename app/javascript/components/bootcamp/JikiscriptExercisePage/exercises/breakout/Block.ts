import { ExecutionContext } from '@/interpreter/executor'
import BreakoutExercise from './BreakoutExercise'
import * as Jiki from '@/interpreter/jikiObjects'

export type BlockInstance = Jiki.Instance & {
  top: Jiki.Number
  left: Jiki.Number
  smashed: Jiki.Boolean
}

function fn(this: BreakoutExercise) {
  const exercise = this

  const hideBlock = (
    executionCtx: ExecutionContext,
    block: Jiki.JikiObject
  ) => {
    this.animateOutOfView(
      executionCtx,
      `#${this.view.id} #block-${block.objectId}`,
      { duration: 150, offset: 0 }
    )
  }

  const Block = new Jiki.Class('Block')
  Block.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    left: Jiki.JikiObject,
    top: Jiki.JikiObject
  ) {
    if (!(left instanceof Jiki.Number) || !(top instanceof Jiki.Number)) {
      return executionCtx.logicError('Left and top must be numbers')
    }
    object.setField('left', left)
    object.setField('top', top)
    object.setField('width', new Jiki.Number(16))
    object.setField('height', new Jiki.Number(exercise.default_block_height))
    object.setField('smashed', new Jiki.Boolean(false))
    if (exercise.autoDrawBlock) {
      exercise.drawBlock(executionCtx, object as BlockInstance)
    }
  })
  Block.addGetter('top', 'public')
  Block.addGetter('left', 'public')
  Block.addGetter('width', 'public')
  Block.addGetter('height', 'public')
  Block.addGetter('smashed', 'public')
  Block.addSetter(
    'smashed',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: Jiki.Instance,
      value: Jiki.JikiObject
    ): void {
      if (!(value instanceof Jiki.Boolean)) {
        return executionCtx.logicError('Smashed must be true or false')
      }
      object.setField('smashed', value)
      if (value.value) {
        hideBlock(executionCtx, object)
      }
    }
  )

  return Block
}

export function buildBlock(binder: any) {
  return fn.bind(binder)()
}
