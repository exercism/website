import { EvaluationResultVariableLookupExpression } from '../evaluation-result'
import { VariableLookupExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { formatLiteral } from '../helpers'

export function describeVariableLookupExpression(
  expression: VariableLookupExpression,
  result: EvaluationResultVariableLookupExpression,
  context: DescriptionContext
) {
  const name = result.name
  const value = formatLiteral(result.resultingValue)
  return [
    `<li>Jiki got the box called <code>${name}</code> off the shelves and took <code>${value}</code> out of it.</li>`,
  ]
}
