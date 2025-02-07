import { EvaluationResultGroupingExpression } from '../evaluation-result'
import { GroupingExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { describeExpression } from './describeSteps'

export function describeGroupingExpression(
  expression: GroupingExpression,
  result: EvaluationResultGroupingExpression,
  context: DescriptionContext
) {
  return describeExpression(expression.inner, result.inner, context)
}
