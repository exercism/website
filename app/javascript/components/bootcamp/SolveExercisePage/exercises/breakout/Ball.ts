import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import BreakoutExercise from './BreakoutExercise'
import { moveCursorByPasteLength } from '../../CodeMirror/extensions/move-cursor-by-paste-length'

export type BallInstance = Jiki.Instance & {}

function fn(this: BreakoutExercise) {
  const exercise = this
  const createBall = (executionCtx: ExecutionContext, ball: BallInstance) => {
    const div = document.createElement('div')
    div.classList.add('ball')
    div.id = `ball-${ball.objectId}`
    div.style.left = `${ball.getUnwrappedField('cx')}%`
    div.style.top = `${ball.getUnwrappedField('cy')}%`
    div.style.width = `${ball.getUnwrappedField('radius') * 2}%`
    div.style.height = `${ball.getUnwrappedField('radius') * 2}%`
    div.style.opacity = '0'
    this.container.appendChild(div)
    this.animateIntoView(
      executionCtx,
      `#${this.view.id} #ball-${ball.objectId}`
    )
  }

  const Ball = new Jiki.Class('Ball')
  Ball.addConstructor(function (
    executionCtx: ExecutionContext,
    ball: Jiki.Instance
  ) {
    ball.setField('cx', new Jiki.Number(50))
    ball.setField('cy', new Jiki.Number(100 - exercise.default_ball_radius))
    ball.setField('radius', new Jiki.Number(exercise.default_ball_radius))
    ball.setField('y_velocity', new Jiki.Number(-1))
    ball.setField('x_velocity', new Jiki.Number(-1))
    createBall(executionCtx, ball)
  })
  Ball.addGetter('cx', 'public')
  Ball.addGetter('cy', 'public')
  Ball.addGetter('radius', 'public')
  Ball.addGetter('x_velocity', 'public')
  Ball.addGetter('y_velocity', 'public')

  function guardVelocity(
    executionCtx: ExecutionContext,
    value: Jiki.JikiObject
  ) {
    if (!(value instanceof Jiki.Number)) {
      return executionCtx.logicError('Velocity must be a number')
    }
    if (value.value == 0) {
      return executionCtx.logicError('Velocity cannot be zero')
    }
  }

  Ball.addSetter(
    'x_velocity',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: BallInstance,
      value: Jiki.JikiObject
    ) {
      guardVelocity(executionCtx, value)
      object.setField('x_velocity', value)
    }
  )
  Ball.addSetter(
    'y_velocity',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: BallInstance,
      value: Jiki.JikiObject
    ) {
      guardVelocity(executionCtx, value)
      object.setField('y_velocity', value)
    }
  )
  Ball.addSetter(
    'cy',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: BallInstance,
      value: Jiki.JikiObject
    ) {
      if (!(value instanceof Jiki.Number)) {
        return executionCtx.logicError('cy must be a number')
      }
      object.setField('cy', value)
      exercise.redrawBall(executionCtx, object)
    }
  )
  Ball.addMethod(
    'move',
    'moved the ball',
    'public',
    function (executionCtx: ExecutionContext, object: BallInstance) {
      exercise.moveBall(executionCtx, object)
    }
  )

  return Ball
}

export function buildBall(binder: any) {
  return fn.bind(binder)()
}
