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
    executionContext: ExecutionContext,
    object: Jiki.Instance,
    row: Jiki.JikiObject,
    col: Jiki.JikiObject,
    in_maze: Jiki.JikiObject,
    is_start: Jiki.JikiObject,
    is_finish: Jiki.JikiObject,
    is_wall: Jiki.JikiObject,
    contents: Jiki.JikiObject
  ) {
    if (!(row instanceof Jiki.Number))
      executionContext.logicError('row must be a Jiki.Number')
    if (!(col instanceof Jiki.Number))
      executionContext.logicError('col must be a Jiki.Number')
    if (!(in_maze instanceof Jiki.Boolean))
      executionContext.logicError('in_maze must be a Jiki.Boolean')
    if (!(is_start instanceof Jiki.Boolean))
      executionContext.logicError('is_start must be a Jiki.Boolean')
    if (!(is_finish instanceof Jiki.Boolean))
      executionContext.logicError('is_finish must be a Jiki.Boolean')
    if (!(is_wall instanceof Jiki.Boolean))
      executionContext.logicError('is_wall must be a Jiki.Boolean')
    if (!(contents instanceof Jiki.String))
      executionContext.logicError('contents must be a Jiki.String')

    object.setField('row', row)
    object.setField('col', col)
    object.setField('is_start', is_start)
    object.setField('is_finish', is_finish)
    object.setField('is_wall', is_wall)
    object.setField('in_maze', in_maze)
    object.setField('contents', contents)
  })
  Square.addGetter('is_start', 'public')
  Square.addGetter('is_finish', 'public')
  Square.addGetter('is_wall', 'public')
  Square.addGetter('in_maze', 'public')
  Square.addGetter('contents', 'public')
  Square.addMethod(
    'remove_emoji',
    'removed the emoji from the square',
    'public',
    function (executionCtx: ExecutionContext, object: Jiki.Instance) {
      removeEmoji(executionCtx, object as SquareInstance)
    }
  )

  return Square
}

export function buildSquare(binder: any) {
  return fn.bind(binder)()
}
