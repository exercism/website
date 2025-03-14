import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import BreakoutExercise from './BreakoutExercise'

type BallInstance = Jiki.Instance & {}

function fn(this: BreakoutExercise) {
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
  Ball['default_radius'] = 3
  Ball.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext
  ) {
    this.fields['cx'] = new Jiki.Number(50)
    this.fields['cy'] = new Jiki.Number(100 - Ball['default_radius'])
    this.fields['radius'] = new Jiki.Number(Ball['default_radius'])
    this.fields['y_velocity'] = new Jiki.Number(-1)
    this.fields['x_velocity'] = new Jiki.Number(-1)
    createBall(executionCtx, this)
  })
  Ball.addGetter('cx')
  Ball.addGetter('cy')
  Ball.addGetter('radius')
  Ball.addGetter('x_velocity')
  Ball.addGetter('y_velocity')

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
    function (
      executionCtx: ExecutionContext,
      object: BallInstance,
      value: Jiki.JikiObject
    ) {
      guardVelocity(executionCtx, value)
      object.setField('y_velocity', value)
    }
  )

  return Ball
}

export function buildBall(binder: any) {
  return fn.bind(binder)()
}
