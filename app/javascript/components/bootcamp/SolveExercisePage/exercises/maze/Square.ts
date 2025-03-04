import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import MazeExercise from './MazeExercise'

export type SquareInstance = Jiki.Instance & {
  start: Jiki.Boolean
  finish: Jiki.Boolean
  wall: Jiki.Boolean
  in_maze: Jiki.Boolean
  contents: Jiki.String
}

function fn(this: MazeExercise) {
  const removeEmoji = (
    executionCtx: ExecutionContext,
    square: SquareInstance
  ) => {
    if (square.getUnwrappedField('contents') === '') {
      executionCtx.logicError(
        'You tried to remove an emoji from a square that does not have one.'
      )
    }

    square.setField('contents', new Jiki.String(''))

    const emojiSelector = `#${this.view.id} .cell-${square.getUnwrappedField(
      'row'
    )}-${square.getUnwrappedField('col')} .emoji`
    this.addAnimation({
      targets: emojiSelector,
      duration: 1,
      transformations: {
        opacity: 0,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }

  const Square = new Jiki.Class('Square')
  Square.addConstructor(function (
    this: Jiki.Instance,
    executionContext: ExecutionContext,
    row: Jiki.Number,
    col: Jiki.Number,
    in_maze: Jiki.Boolean,
    is_start: Jiki.Boolean,
    is_finish: Jiki.Boolean,
    is_wall: Jiki.Boolean,
    contents: Jiki.String
  ) {
    this.fields['row'] = row
    this.fields['col'] = col
    this.fields['is_start'] = is_start
    this.fields['is_finish'] = is_finish
    this.fields['is_wall'] = is_wall
    this.fields['in_maze'] = in_maze
    this.fields['contents'] = contents
  })
  Square.addGetter('is_start')
  Square.addGetter('is_finish')
  Square.addGetter('is_wall')
  Square.addGetter('in_maze')
  Square.addGetter('contents')
  Square.addMethod(
    'remove_emoji',
    function (this: Jiki.Instance, executionCtx: ExecutionContext) {
      removeEmoji(executionCtx, this as SquareInstance)
      return null
    }
  )

  return Square
}

export function buildSquare(binder: any) {
  return fn.bind(binder)()
}
