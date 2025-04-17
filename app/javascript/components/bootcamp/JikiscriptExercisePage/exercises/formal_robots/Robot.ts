import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import FormalRobotsExercise from './FormalRobotsExercise'

export type RobotInstance = Jiki.Instance & {}

function fn(this: FormalRobotsExercise) {
  const exercise = this
  const Robot = new Jiki.Class('Robot')
  Robot.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance
  ) {
    const name = exercise.robotNames.shift() || ''
    const age = exercise.robotAges.shift() || 0
    object.setField('name', new Jiki.String(name))
    object.setField('age', new Jiki.Number(age))
  })
  Robot.addGetter('age', 'public')
  Robot.addMethod(
    'say',
    'caused the robot to say ${arg1}',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: RobotInstance,
      utterence: Jiki.JikiObject
    ) {
      if (!(utterence instanceof Jiki.String)) {
        return executionCtx.logicError('What the robot says must be a string')
      }
      exercise.interactions.push(
        `${object.getUnwrappedField('name')}: ${utterence.value}`
      )
    }
  )
  return Robot
}

export function buildRobot(binder: any) {
  return fn.bind(binder)()
}
