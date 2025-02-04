import { EvaluationResultIfStatement } from '../evaluation-result'
import { Expression } from '../expression'
import { FrameWithResult } from '../frames'
import { IfStatement } from '../statement'
import { describeExpression } from './describeExpression'

export function describeIfStatement(frame: FrameWithResult) {
  const ifStatement = frame.context as IfStatement
  const conditionDescription = describeCondition(
    ifStatement.condition,
    frame.result as EvaluationResultIfStatement
  )

  return (
    `<p>This checked whether ${conditionDescription}</p>` +
    `<p>The result was <code>${frame.result.value}</code>.</p>`
  ).trim()
}

export function describeCondition(
  expression: Expression,
  result: EvaluationResultIfStatement
): string {
  return describeExpression(expression, result.condition)
}
