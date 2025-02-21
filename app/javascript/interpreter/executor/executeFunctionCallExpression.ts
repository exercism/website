import { Executor } from '../executor'
import { FunctionCallExpression, MethodCallExpression } from '../expression'
import {
  FunctionCallTypeMismatchError,
  isRuntimeError,
  LogicError,
} from '../error'
import { Arity, isCallable } from '../functions'
import {
  EvaluationResult,
  EvaluationResultFunctionCallExpression,
  EvaluationResultFunctionLookupExpression,
} from '../evaluation-result'
import { isNumber } from '../checks'
import { cloneDeep } from 'lodash'
import { JikiObject, wrapJSToJikiObject } from '../jikiObjects'
import { Location } from '../location'

function throwMissingFunctionError(
  executor: Executor,
  expression: FunctionCallExpression,
  e: Error
) {
  if (!isRuntimeError(e)) {
    throw e
  }
  if (e.type != 'CouldNotFindFunction') {
    throw e
  }

  if (e.context?.didYouMean?.function?.length > 0) {
    const alternative = e.context.didYouMean.function
    executor.error('CouldNotFindFunctionWithSuggestion', e.location, {
      ...e.context,
      suggestion: alternative,
      name: expression.callee.name.lexeme,
    })
  }

  executor.error('CouldNotFindFunction', e.location, {
    ...e.context,
    ...{
      name: expression.callee.name.lexeme,
    },
  })
}

export function executeFunctionCallExpression(
  executor: Executor,
  expression: FunctionCallExpression
): EvaluationResultFunctionCallExpression {
  let ce

  // The catch here always rethrows the error.
  try {
    ce = executor.evaluate(expression.callee)
  } catch (e: Error) {
    throwMissingFunctionError(executor, expression, e)
  }
  const callee = ce as EvaluationResultFunctionLookupExpression

  if (!isCallable(callee.function)) {
    executor.error('NonCallableTarget', expression.location, { callee })
  }

  const args: EvaluationResult[] = []
  for (const arg of expression.args) {
    args.push(executor.evaluate(arg))
  }
  const arity = callee.function.arity
  guardArityOnCallExpression(
    executor,
    arity,
    args,
    expression.location,
    callee.name
  )

  const fnName = callee.name
  let value: JikiObject

  executor.addFunctionToCallStack(fnName, expression)

  try {
    // Log it's usage for testing checks
    const argResults = args.map((arg) => cloneDeep(arg.jikiObject))
    executor.addFunctionCallToLog(fnName, argResults)

    value = callee.function.call(
      executor.getExecutionContext(),
      args.map((arg) => arg.jikiObject?.toArg())
    )
    value = wrapJSToJikiObject(value)
  } catch (e) {
    if (e instanceof FunctionCallTypeMismatchError) {
      executor.error('FunctionCallTypeMismatch', expression.location, e.context)
    } else if (e instanceof LogicError) {
      executor.error('LogicError', expression.location, { message: e.message })
    } else {
      throw e
    }
  } finally {
    executor.popCallStack()
  }

  return {
    type: 'FunctionCallExpression',
    jikiObject: value,
    callee,
    args,
  }
}

export function guardArityOnCallExpression(
  executor: Executor,
  arity: Arity,
  args: EvaluationResult[],
  location: Location,
  name: string
) {
  const [minArity, maxArity] = isNumber(arity) ? [arity, arity] : arity

  if (args.length < minArity || args.length > maxArity) {
    if (minArity !== maxArity) {
      executor.error(
        'InvalidNumberOfArgumentsWithOptionalArguments',
        location,
        {
          name,
          minArity,
          maxArity,
          numberOfArgs: args.length,
        }
      )
    }

    if (args.length < minArity) {
      executor.error('TooFewArguments', location, {
        name,
        arity: maxArity,
        numberOfArgs: args.length,
        args,
      })
    } else {
      executor.error('TooManyArguments', location, {
        name,
        arity: maxArity,
        numberOfArgs: args.length,
        args,
      })
    }
  }
}
