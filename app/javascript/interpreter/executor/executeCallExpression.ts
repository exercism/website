import { Executor } from '../executor'
import { CallExpression } from '../expression'
import {
  FunctionCallTypeMismatchError,
  isRuntimeError,
  LogicError,
} from '../error'
import { isCallable } from '../functions'
import {
  EvaluationResult,
  EvaluationResultCallExpression,
  EvaluationResultFunctionLookupExpression,
} from '../evaluation-result'
import { isNumber } from '../checks'
import { cloneDeep } from 'lodash'
import { wrapJSToJikiObject } from '../jikiTypes'

function throwMissingFunctionError(
  executor: Executor,
  expression: CallExpression,
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

export function executeCallExpression(
  executor: Executor,
  expression: CallExpression
): EvaluationResultCallExpression {
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
  const [minArity, maxArity] = isNumber(arity) ? [arity, arity] : arity

  if (args.length < minArity || args.length > maxArity) {
    if (minArity !== maxArity) {
      executor.error(
        'InvalidNumberOfArgumentsWithOptionalArguments',
        expression.paren.location,
        {
          name: expression.callee.name.lexeme,
          minArity,
          maxArity,
          numberOfArgs: args.length,
        }
      )
    }

    if (args.length < minArity) {
      executor.error('TooFewArguments', expression.paren.location, {
        name: expression.callee.name.lexeme,
        arity: maxArity,
        numberOfArgs: args.length,
        args,
      })
    } else {
      executor.error('TooManyArguments', expression.paren.location, {
        name: expression.callee.name.lexeme,
        arity: maxArity,
        numberOfArgs: args.length,
        args,
      })
    }
  }

  const fnName = callee.name
  let value: EvaluationResultCallExpression

  try {
    // Log it's usage for testing checks
    const argResults = args.map((arg) => cloneDeep(arg.jikiObject))
    executor.addFunctionCallToLog(fnName, argResults)
    executor.addFunctionToCallStack(fnName, expression)

    value = callee.function.call(
      executor.getExecutionContext(),
      args.map((arg) => cloneDeep(arg.jikiObject))
    )
    value = wrapJSToJikiObject(value)

    executor.popCallStack()
  } catch (e) {
    if (e instanceof FunctionCallTypeMismatchError) {
      executor.error('FunctionCallTypeMismatch', expression.location, e.context)
    } else if (e instanceof LogicError) {
      executor.error('LogicError', expression.location, { message: e.message })
    } else {
      throw e
    }
  }

  return {
    type: 'CallExpression',
    jikiObject: value,
    callee,
    args,
  }
}
