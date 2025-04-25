import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import BreakoutExercise from './BreakoutExercise'

export type PaddleInstance = Jiki.Instance & {}

function fn(this: BreakoutExercise) {
  const exercise = this

  const createPaddle = (
    executionCtx: ExecutionContext,
    paddle: PaddleInstance
  ) => {
    const div = document.createElement('div')
    div.classList.add('paddle')
    div.id = `paddle-${paddle.objectId}`
    div.style.left = `${paddle.getUnwrappedField('cx')}%`
    div.style.top = `${paddle.getUnwrappedField('cy')}%`
    div.style.width = `${paddle.getUnwrappedField('width')}%`
    div.style.height = `${paddle.getUnwrappedField('height')}%`
    div.style.opacity = '0'
    this.container.appendChild(div)
    this.animateIntoView(
      executionCtx,
      `#${this.view.id} #paddle-${paddle.objectId}`
    )
  }
  const move = (executionCtx: ExecutionContext, paddle: PaddleInstance) => {
    this.addAnimation({
      targets: `#${this.view.id} #paddle-${paddle.objectId}`,
      duration: 1,
      transformations: {
        left: `${paddle.getUnwrappedField('cx')}%`,
        top: `${paddle.getUnwrappedField('cy')}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(1)
  }

  const Paddle = new Jiki.Class('Paddle')
  Paddle['default_width'] = 20
  Paddle['default_height'] = 4
  Paddle['default_cy'] = 97
  Paddle.addConstructor(function (
    executionCtx: ExecutionContext,
    paddle: Jiki.Instance
  ) {
    paddle.setField('cx', new Jiki.Number(50))
    paddle.setField('cy', new Jiki.Number(Paddle['default_cy']))
    paddle.setField('width', new Jiki.Number(Paddle['default_width']))
    paddle.setField('height', new Jiki.Number(Paddle['default_height']))
    createPaddle(executionCtx, paddle)
  })
  Paddle.addGetter('cx', 'public')
  Paddle.addGetter('cy', 'public')
  Paddle.addGetter('height', 'public')
  Paddle.addGetter('width', 'public')

  Paddle.addMethod(
    'move_left',
    'moved the paddle left 0.85 units',
    'public',
    function (executionCtx: ExecutionContext, paddle: PaddleInstance) {
      const newCx = paddle.getUnwrappedField('cx') - 0.85
      if (newCx - paddle.getUnwrappedField('width') / 2 < 0) {
        return executionCtx.logicError(
          'Paddle cannot move off the left of the screen'
        )
      }
      if (newCx + paddle.getUnwrappedField('width') / 2 > 100) {
        return executionCtx.logicError(
          'Paddle cannot move off the right of the screen'
        )
      }
      if (exercise.lastMovedItem == 'paddle') {
        return executionCtx.logicError(
          'You cannot move the Paddle twice in a row.'
        )
      }

      paddle.setField('cx', new Jiki.Number(newCx))
      exercise.lastMovedItem = 'paddle'
      move(executionCtx, paddle)
    }
  )

  Paddle.addMethod(
    'move_right',
    'moved the paddle right 0.9 units',
    'public',
    function (executionCtx: ExecutionContext, paddle: PaddleInstance) {
      const newCx = paddle.getUnwrappedField('cx') + 0.9
      if (newCx - paddle.getUnwrappedField('width') / 2 < 0) {
        return executionCtx.logicError(
          'Paddle cannot move off the left of the screen'
        )
      }
      if (newCx + paddle.getUnwrappedField('width') / 2 > 100) {
        return executionCtx.logicError(
          'Paddle cannot move off the right of the screen'
        )
      }

      paddle.setField('cx', new Jiki.Number(newCx))
      move(executionCtx, paddle)
    }
  )

  return Paddle
}

export function buildPaddle(binder: any) {
  return fn.bind(binder)()
}
