import { Executor } from '../executor'
import { CallExpression } from '../expression'
import {
  FunctionCallTypeMismatchError,
  isRuntimeError,
  LogicError,
} from '../error'
import { isCallable } from '../functions'
import { EvaluationResult } from '../evaluation-result'
import { isNumber } from '../checks'

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
): EvaluationResult {
  let callee: any

  // The catch here always rethrows the error.
  try {
    callee = executor.evaluate(expression.callee)
  } catch (e: Error) {
    throwMissingFunctionError(executor, expression, e)
  }

  if (!isCallable(callee.value)) {
    executor.error('NonCallableTarget', expression.location, { callee })
  }

  const args: EvaluationResult[] = []
  for (const arg of expression.args) args.push(executor.evaluate(arg))

  const arity = callee.value.arity()
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
  let value

  try {
    // Log it's usage for testing checks
    executor.addFunctionCallToLog(fnName, args)

    value = callee.value.call(
      executor.getExecutionContext(),
      args.map((arg) => arg.value)
    )
  } catch (e) {
    if (e instanceof FunctionCallTypeMismatchError) {
      executor.error('FunctionCallTypeMismatch', expression.location, e.context)
    }
    if (e instanceof LogicError) {
      executor.error('LogicError', expression.location, { message: e.message })
    } else {
      throw e
    }
  }

  return {
    type: 'CallExpression',
    callee,
    args,
    value,
  }
}
