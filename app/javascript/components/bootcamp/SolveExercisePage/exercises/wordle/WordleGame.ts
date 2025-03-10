import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import WordleExercise from './WordleExercise'

function fn(this: WordleExercise) {
  const exercise = this
  const WordleGame = new Jiki.Class('WordleGame')
  WordleGame.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext
  ) {})
  WordleGame.addGetter(
    'target_word',
    function (executionCtx: ExecutionContext) {
      return new Jiki.String(exercise.targetWord)
    }
  )
  WordleGame.addMethod('draw_board', function (executionCtx: ExecutionContext) {
    exercise.setupView()

    return null
  })
  WordleGame.addMethod(
    'add_word',
    function (
      executionCtx: ExecutionContext,
      row: Jiki.Number,
      word: Jiki.String,
      states: Jiki.List
    ) {
      exercise.drawGuess(executionCtx, row.value - 1, word.value)
      exercise.colorRow(executionCtx, row, states)
      return null
    }
  )
  return WordleGame
}

export function buildWordleGame(binder: any) {
  return fn.bind(binder)()
}
