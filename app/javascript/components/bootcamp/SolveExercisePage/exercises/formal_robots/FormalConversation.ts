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
  FormalConversation.addGetter(
    'participant_1_name',
    function (
      executionCtx: ExecutionContext,
      object: FormalConversationInstance
    ) {
      return (object.getField('robot1') as RobotInstance).getField('name')
    }
  )
  FormalConversation.addGetter(
    'participant_2_name',
    function (
      executionCtx: ExecutionContext,
      object: FormalConversationInstance
    ) {
      return (object.getField('robot2') as RobotInstance).getField('name')
    }
  )
  FormalConversation.addMethod(
    'exchange_salutations',
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
