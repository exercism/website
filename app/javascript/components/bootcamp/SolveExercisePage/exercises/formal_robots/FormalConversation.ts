import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'
import FormalRobotsExercise from './FormalRobotsExercise'
import { RobotInstance } from './Robot'

type FormalConversationInstance = Jiki.Instance & {}

function fn(this: FormalRobotsExercise) {
  const exercise = this
  const FormalConversation = new Jiki.Class('FormalConversation')
  FormalConversation.addConstructor(function (
    executionCtx: ExecutionContext,
    object: Jiki.Instance,
    robot1: Jiki.JikiObject,
    robot2: Jiki.JikiObject
  ) {
    if (!(robot1 instanceof Jiki.Instance && robot1 instanceof Jiki.Instance)) {
      executionCtx.logicError('Both participants must be robots')
    }
    object.setField('robot1', robot1)
    object.setField('robot2', robot2)
  })
  FormalConversation.addMethod(
    'get_participant_name',
    "returned the participant's name at index ${arg1}",
    'public',

    function (
      executionCtx: ExecutionContext,
      object: FormalConversationInstance,
      idx: Jiki.JikiObject
    ) {
      if (!(idx instanceof Jiki.Number)) {
        return executionCtx.logicError('Index must be a number')
      }
      if (idx.value !== 1 && idx.value !== 2) {
        return executionCtx.logicError('Index must be 1 or 2')
      }
      return (object.getField(`robot${idx.value}`) as RobotInstance).getField(
        'name'
      )
    }
  )
  FormalConversation.addMethod(
    'exchange_salutations',
    'caused the robots to greet each other',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: FormalConversationInstance
    ) {
      const r1 = object.getField('robot1') as RobotInstance
      const r2 = object.getField('robot2') as RobotInstance
      exercise.interactions.push(
        `${r1.getUnwrappedField('name')}: Hello ⚡☂♞✿☯.`,
        `${r2.getUnwrappedField('name')}: Hello ✦☀♻❄☘.`
      )
    }
  )
  FormalConversation.addMethod(
    'exchange_valedictions',
    'caused the robots to say goodbye',
    'public',
    function (
      executionCtx: ExecutionContext,
      object: FormalConversationInstance
    ) {
      const r1 = object.getField('robot1') as RobotInstance
      const r2 = object.getField('robot2') as RobotInstance
      exercise.interactions.push(
        `${r1.getUnwrappedField('name')}: Goodbye ★⚔♠✧❀.`,
        `${r2.getUnwrappedField('name')}: Goodbye ♜⚙❖☾✺.`
      )
    }
  )
  return FormalConversation
}

export function buildFormalConversation(binder: any) {
  return fn.bind(binder)()
}
