import { LogicError } from '../error'
import {
  EvaluationResult,
  EvaluationResultMethodCallExpression,
} from '../evaluation-result'
import { Executor } from '../executor'
import { MethodCallExpression } from '../expression'
import { Callable, UserDefinedMethod } from '../functions'
import * as Jiki from '../jikiObjects'
import { guardArityOnCallExpression } from './executeFunctionCallExpression'

export function executeMethodCallExpression(
  executor: Executor,
  expression: MethodCallExpression
): EvaluationResultMethodCallExpression {
  const object = executor.evaluate(expression.object)

  const methodName = expression.methodName.lexeme

  if (!(object.jikiObject instanceof Jiki.Instance)) {
    return executor.error('AccessorUsedOnNonInstance', expression.location)
  }

  const method = object.jikiObject.getMethod(methodName)
  if (method === undefined) {
    executor.error('CouldNotFindMethod', expression.location, {
      name: methodName,
    })
  }

  if (
    method.visibility === 'private' &&
    expression.object.type != 'ThisExpression'
  ) {
    executor.error('AttemptedToAccessPrivateMethod', expression.location, {
      name: methodName,
    })
  }

  const args: EvaluationResult[] = []
  for (const arg of expression.args) {
    args.push(executor.evaluate(arg))
  }

  guardArityOnCallExpression(
    executor,
    method.arity,
    args,
    expression.location,
    methodName
  )

  const callableArgs: Jiki.JikiObject[] = args
    .map((arg) => arg.jikiObject)
    .filter((arg) => arg !== undefined)
    .map((arg) => arg.toArg())

  let jikiObject
  try {
    executor.addFunctionToCallStack(methodName, expression)
    jikiObject = executor.withThis(object.jikiObject, () => {
      if (method.fn instanceof UserDefinedMethod) {
        return method.fn.call(executor.getExecutionContext(), callableArgs)
      } else {
        return method.fn.call(
          undefined,
          executor.getExecutionContext(),
          object.jikiObject as Jiki.Instance,
          ...callableArgs
        )
      }
    })
  } catch (e: unknown) {
    if (e instanceof LogicError) {
      executor.error('LogicError', expression.location, { message: e.message })
    }
    throw e
  } finally {
    executor.popCallStack()
  }

  return {
    type: 'MethodCallExpression',
    jikiObject,
    method: method,
    object: object,
    args,
  }
}
