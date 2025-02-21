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

  const args: EvaluationResultExpression[] = []
  for (const arg of expression.args) {
    const evaluatedArg = executor.evaluate(arg)
    if (!(evaluatedArg.jikiObject instanceof JikiTypes.JikiObject)) {
      throw 'URGH'
    }
    args.push(evaluatedArg)
  }
  const object = jikiClass.instantiate(
    args.map((arg) => (arg.jikiObject as JikiTypes.JikiObject).toArg())
  )

  return {
    type: 'InstantiationExpression',
    jikiObject: object,
    className,
    args: args,
  }
}
