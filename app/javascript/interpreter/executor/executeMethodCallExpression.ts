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
    object: object,
    args,
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
