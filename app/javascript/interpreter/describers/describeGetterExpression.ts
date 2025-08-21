import {
  EvaluationResultBinaryExpression,
  EvaluationResultGetterExpression,
} from '../evaluation-result'
import { AccessorExpression, BinaryExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { describeExpression } from './describeSteps'

export function describeGetterExpression(
  expression: AccessorExpression,
  result: EvaluationResultGetterExpression,
  context: DescriptionContext
) {
  const objectSteps = describeExpression(
    expression.object,
    result.object,
    context
  )
  const finalStep = `<li>Jiki got the value of the ${codeTag(
    expression.property.lexeme,
    expression.property.location
  )} property and determined it was ${codeTag(
    result.jikiObject,
    expression.location
  )}.</li>`
  return [...objectSteps, finalStep]
}
