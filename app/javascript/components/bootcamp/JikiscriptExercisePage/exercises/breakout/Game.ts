import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import BreakoutExercise from './BreakoutExercise'
import { BlockInstance, buildBlock } from './Block'
import { bindAll } from 'lodash'
import { buildBall, type BallInstance } from './Ball'
import { buildPaddle, type PaddleInstance } from './Paddle'

export type GameInstance = Jiki.Instance & {
  ball: BallInstance
  paddle: PaddleInstance
}

function fn(this: BreakoutExercise) {
  const exercise = this
  const Block = buildBlock(exercise)
  const Ball = buildBall(exercise)
  const Paddle = buildPaddle(exercise)

  const Game = new Jiki.Class('Game')
  Game.addConstructor(function (
    executionCtx: ExecutionContext,
    game: Jiki.Instance
  ) {
    const ball = Ball.instantiate(executionCtx, [])
    ball.setField('cy', new Jiki.Number(95 - exercise.default_ball_radius))
    exercise.redrawBall(executionCtx, ball)
    exercise.gameInstance = game as GameInstance

    game.setField('ball', ball)
    game.setField('paddle', Paddle.instantiate(executionCtx, []))
    game.setField('blocks', new Jiki.List([]))
  })

  Game.addGetter('ball', 'public')
  Game.addSetter('ball', 'public')
  Game.addGetter('paddle', 'public')
  Game.addSetter('paddle', 'public')
  Game.addGetter('blocks', 'public')

  Game.addMethod(
    'add_block',
    'added a block to the game',
    'public',
    function (
      executionCtx: ExecutionContext,
      game: Jiki.Instance,
      block: Jiki.JikiObject
    ) {
      if (!(block instanceof Jiki.Instance)) {
        return executionCtx.logicError('block must be a Block')
      }
      ;(game.getField('blocks') as Jiki.List).value.push(block)
      exercise.drawBlock(executionCtx, block as BlockInstance)
    }
  )

  Game.addMethod(
    'game_over',
    'set the game as over',
    'public',
    function (
      executionCtx: ExecutionContext,
      game: Jiki.Instance,
      result: Jiki.JikiObject
    ) {
      exercise.gameOver(executionCtx, result)
    }
  )

  return Game
}

export function buildGame(binder: any) {
  return fn.bind(binder)()
}
