import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import ChattyRobotsExercise from './ChattyRobotsExercise'

type RobotInstance = Jiki.Instance & {}

function fn(this: ChattyRobotsExercise) {
  const exercise = this
  const Robot = new Jiki.Class('Robot')
  Robot.addConstructor(function (
    this: Jiki.Instance,
    executionCtx: ExecutionContext,
    name: Jiki.String,
    age: Jiki.Number
  ) {
    this.fields['name'] = name
    this.fields['age'] = age
  })
  Robot.addGetter('name')
  Robot.addGetter('age')
  Robot.addMethod(
    'say_hello',
    function (this: RobotInstance, executionCtx: ExecutionContext) {
      exercise.interactions.push(
        `${this.getUnwrappedField('name')}: Hello 123!`
      )

      return null
    }
  )

  Robot.addMethod(
    'say',
    function (
      this: RobotInstance,
      executionCtx: ExecutionContext,
      utterence: Jiki.String
    ) {
      exercise.interactions.push(
        `${this.getUnwrappedField('name')}: ${utterence.value}`
      )

      return null
    }
  )
  Robot.addMethod(
    'say_goodbye',
    function (this: RobotInstance, executionCtx: ExecutionContext) {
      exercise.interactions.push(
        `${this.getUnwrappedField('name')}: Goodbye 456!`
      )

      return null
    }
  )
  return Robot
}

export function buildRobot(binder: any) {
  return fn.bind(binder)()
}
