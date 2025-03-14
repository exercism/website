import { ExecutionContext } from '@/interpreter/executor'
import BreakoutExercise from './BreakoutExercise'
import * as Jiki from '@/interpreter/jikiObjects'

export type BlockInstance = Jiki.Instance & {
  top: Jiki.Number
  left: Jiki.Number
  smashed: Jiki.Boolean
}

function fn(this: BreakoutExercise) {
  const createBlock = (
    executionCtx: ExecutionContext,
    block: BlockInstance
  ) => {
    this.blocks.push(block)

    const div = document.createElement('div')
    div.classList.add('block')
    div.id = `block-${block.objectId}`
    div.style.left = `${block.getUnwrappedField('left')}%`
    div.style.top = `${block.getUnwrappedField('top')}%`
    div.style.width = `${block.getUnwrappedField('width')}%`
    div.style.height = `${block.getUnwrappedField('height')}%`
    div.style.opacity = '0'
    this.container.appendChild(div)

    this.animateIntoView(
      executionCtx,
      `#${this.view.id} #block-${block.objectId}`
    )
  }
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
  Block['default_height'] = 7
  Block.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    left: Jiki.Number,
    top: Jiki.Number
  ) {
    this.fields['left'] = left
    this.fields['top'] = top
    this.fields['width'] = new Jiki.Number(16)
    this.fields['height'] = new Jiki.Number(Block['default_height'])
    this.fields['smashed'] = new Jiki.Boolean(false)
    createBlock(executionCtx, this as BlockInstance)
  })
  Block.addGetter('top')
  Block.addGetter('left')
  Block.addGetter('width')
  Block.addGetter('height')
  Block.addGetter('smashed')
  Block.addSetter(
    'smashed',
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
