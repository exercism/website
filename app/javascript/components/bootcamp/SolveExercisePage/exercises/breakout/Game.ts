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
  const Block = buildBlock(this)
  const Ball = buildBall(this)
  const Paddle = buildPaddle(this)

  const gameOverWin = (executionCtx: ExecutionContext) => {
    this.gameOverWinView = document.createElement('div')
    this.gameOverWinView.classList.add('game-over-win')
    this.gameOverWinView.style.opacity = '0'
    this.view.appendChild(this.gameOverWinView)
    this.addAnimation({
      targets: `#${this.view.id} .game-over-win`,
      duration: 100,
      transformations: {
        opacity: 0.9,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(100)
  }

  const gameOverLose = (executionCtx: ExecutionContext) => {
    this.gameOverLoseView = document.createElement('div')
    this.gameOverLoseView.classList.add('game-over-lose')
    this.gameOverLoseView.style.opacity = '0'
    this.view.appendChild(this.gameOverLoseView)
    this.addAnimation({
      targets: `#${this.view.id} .game-over-lose`,
      duration: 100,
      transformations: {
        opacity: 0.9,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(100)
  }

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
    'public',
    function (
      executionCtx: ExecutionContext,
      game: GameInstance,
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
    'public',
    function (
      executionCtx: ExecutionContext,
      game: GameInstance,
      result: Jiki.JikiObject
    ) {
      if (!(result instanceof Jiki.String)) {
        return executionCtx.logicError('Result must be either "win" or "lose"')
      }
      if (!(result.value === 'win' || result.value === 'lose')) {
        return executionCtx.logicError('Result must be either "win" or "lose"')
      }
      game.setField('result', result)

      if (result.value === 'win') {
        gameOverWin(executionCtx)
      }
      if (result.value === 'lose') {
        gameOverLose(executionCtx)
      }
    }
  )

  return Game
}

export function buildGame(binder: any) {
  return fn.bind(binder)()
}
