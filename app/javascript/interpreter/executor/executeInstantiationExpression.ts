import { isArray, isNumber } from 'lodash'

import {
  EvaluationResult,
  EvaluationResultBinaryExpression,
  EvaluationResultClassLookupExpression,
  EvaluationResultExpression,
  EvaluationResultInstantiationExpression,
  EvaluationResultVariableLookupExpression,
} from '../evaluation-result'
import { Executor } from '../executor'
import { BinaryExpression, InstantiationExpression } from '../expression'
import * as JikiTypes from '../jikiObjects'

export function executeInstantiationExpression(
  executor: Executor,
  expression: InstantiationExpression
): EvaluationResultInstantiationExpression {
  const className = executor.evaluate(
    expression.className
  ) as EvaluationResultClassLookupExpression
  const jikiClass = className.class

  if (expression.args.length !== jikiClass.arity) {
    executor.error('WrongNumberOfArguments', expression.location, {
      expected: jikiClass.arity,
      got: expression.args.length,
    })
  }
  const args: EvaluationResultExpression[] = []
  for (const arg of expression.args) {
    const evaluatedArg = executor.evaluate(arg)
    if (!(evaluatedArg.jikiObject instanceof JikiTypes.JikiObject)) {
      throw 'URGH'
    }
    args.push(evaluatedArg)
  }
  const object = jikiClass.instantiate(
    executor.getExecutionContext(),
    args.map((arg) => (arg.jikiObject as JikiTypes.JikiObject).toArg())
  )

  return {
    type: 'InstantiationExpression',
    jikiObject: object,
    className,
    args: args,
  }
}
