import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import WordleExercise from './WordleExercise'

function fn(this: WordleExercise) {
  const exercise = this
  const WordleGame = new Jiki.Class('WordleGame')

  WordleGame.addGetter(
    'target_word',
    'public',
    function (executionCtx: ExecutionContext, object: Jiki.Instance) {
      return new Jiki.String(exercise.targetWord)
    }
  )
  WordleGame.addMethod(
    'draw_board',
    'drew the board',
    'public',
    function (executionCtx: ExecutionContext, _: Jiki.Instance) {
      exercise.setupView(executionCtx)
    }
  )
  WordleGame.addMethod(
    'add_word',
    'added a word to the board',
    'public',
    function (
      executionCtx: ExecutionContext,
      _: Jiki.Instance,
      row: Jiki.JikiObject,
      word: Jiki.JikiObject,
      states: Jiki.JikiObject
    ) {
      if (!(row instanceof Jiki.Number)) {
        return executionCtx.logicError('The first input must be a number')
      }
      if (row.value < 1 || row.value > 6) {
        return executionCtx.logicError(
          `The first input must be between 1 and 6 (it was ${row.value}).`
        )
      }
      if (!(word instanceof Jiki.String)) {
        return executionCtx.logicError('Word must be a string')
      }
      if (!(states instanceof Jiki.List)) {
        return executionCtx.logicError('States must be a list')
      }
      exercise.drawGuess(executionCtx, row.value - 1, word.value)
      exercise.colorRow(executionCtx, row, states)
    }
  )
  return WordleGame
}

export function buildWordleGame(binder: any) {
  return fn.bind(binder)()
}
