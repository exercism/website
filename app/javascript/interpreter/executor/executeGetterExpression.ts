import { LogicError } from '../error'
import {
  EvaluationResult,
  EvaluationResultGetterExpression,
  EvaluationResultMethodCallExpression,
} from '../evaluation-result'
import { Executor } from '../executor'
import { AccessorExpression, MethodCallExpression } from '../expression'
import * as Jiki from '../jikiObjects'
import { guardArityOnCallExpression } from './executeFunctionCallExpression'

export function executeGetterExpression(
  executor: Executor,
  expression: AccessorExpression
): EvaluationResultGetterExpression {
  const object = executor.evaluate(expression.object)
  if (!(object.jikiObject instanceof Jiki.Instance)) {
    executor.error('AccessorUsedOnNonInstance', expression.location)
  }
  if (!(object.jikiObject instanceof Jiki.Instance)) {
    executor.error('AccessorUsedOnNonInstance', expression.location)
  }
  const getterName = expression.property.lexeme
  const getter = object.jikiObject.getGetter(getterName)

  if (!getter) {
    if (object.jikiObject.getMethod(getterName)) {
      executor.error('MethodUsedAsGetter', expression.property.location, {
        name: getterName,
      })
    }
    executor.error('CouldNotFindGetter', expression.property.location, {
      name: getterName,
    })
  }
  if (
    getter.visibility === 'private' &&
    expression.object.type !== 'ThisExpression'
  ) {
    executor.error(
      'AttemptedToAccessPrivateGetter',
      expression.property.location,
      {
        name: getterName,
      }
    )
  }

  let value
  try {
    value = getter.fn.apply(undefined, [
      executor.getExecutionContext(),
      object.jikiObject as Jiki.Instance,
    ])
  } catch (e: unknown) {
    if (e instanceof LogicError) {
      executor.error('LogicError', expression.location, { message: e.message })
    }
    throw e
  }

  return {
    type: 'GetterExpression',
    jikiObject: value,
    object,
  }
}
/*
  let ce

  // The catch here always rethrows the error.
  try {
    ce = executor.evaluate(expression.callee)
  } catch (e: Error) {
    throwMissingMethodError(executor, expression, e)
  }
  const callee = ce as EvaluationResultMethodLookupExpression

  if (!isCallable(callee.method)) {
    executor.error('NonCallableTarget', expression.location, { callee })
  }

  const args: EvaluationResult[] = []
  for (const arg of expression.args) {
    args.push(executor.evaluate(arg))
  }

  const arity = callee.method.arity
  const [minArity, maxArity] = isNumber(arity) ? [arity, arity] : arity

  if (args.length < minArity || args.length > maxArity) {
    if (minArity !== maxArity) {
      executor.error(
        'InvalidNumberOfArgumentsWithOptionalArguments',
        expression.callee.location,
        {
          name: expression.callee.name.lexeme,
          minArity,
          maxArity,
          numberOfArgs: args.length,
        }
      )
    }

    if (args.length < minArity) {
      executor.error('TooFewArguments', expression.callee.location, {
        name: expression.callee.name.lexeme,
        arity: maxArity,
        numberOfArgs: args.length,
        args,
      })
    } else {
      executor.error('TooManyArguments', expression.callee.location, {
        name: expression.callee.name.lexeme,
        arity: maxArity,
        numberOfArgs: args.length,
        args,
      })
    }
  }

  const fnName = callee.name
  let value: JikiObject

  try {
    // Log it's usage for testing checks
    const argResults = args.map((arg) => cloneDeep(arg.jikiObject))
    executor.addMethodCallToLog(fnName, argResults)
    executor.addMethodToCallStack(fnName, expression)

    value = callee.method.call(
      executor.getExecutionContext(),
      args.map((arg) => cloneDeep(arg.jikiObject))
    )
    value = wrapJSToJikiObject(value)

    executor.popCallStack()
  } catch (e) {
    if (e instanceof MethodCallTypeMismatchError) {
      executor.error('MethodCallTypeMismatch', expression.location, e.context)
    } else if (e instanceof LogicError) {
      executor.error('LogicError', expression.location, { message: e.message })
    } else {
      throw e
    }
  }

  return {
    type: 'MethodCallExpression',
    jikiObject: value,
    callee,
    args,
  }
}
*/
