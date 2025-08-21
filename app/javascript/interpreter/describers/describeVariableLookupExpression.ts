import { EvaluationResultVariableLookupExpression } from '../evaluation-result'
import { VariableLookupExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'

export function describeVariableLookupExpression(
  expression: VariableLookupExpression,
  result: EvaluationResultVariableLookupExpression,
  context: DescriptionContext
) {
  const name = result.name
  const value = formatJikiObject(result.jikiObject)
  return [
    `<li>Jiki got the box called ${codeTag(
      name,
      expression.location
    )} off the shelves and took ${codeTag(
      value,
      expression.location
    )} out of it.</li>`,
  ]
}
