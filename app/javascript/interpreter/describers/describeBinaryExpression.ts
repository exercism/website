import { EvaluationResultBinaryExpression } from '../evaluation-result'
import { BinaryExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { formatLiteral } from '../helpers'
import { describeExpression } from './describeSteps'

export function describeBinaryExpression(
  expression: BinaryExpression,
  result: EvaluationResultBinaryExpression,
  context: DescriptionContext
) {
  const leftSteps = describeExpression(expression.left, result.left, context)
  const rightSteps = describeExpression(expression.right, result.right, context)

  const leftRes = formatLiteral(result.left.jikiObject)
  const op = expression.operator.lexeme
  const rightRes = formatLiteral(result.right.jikiObject)

  const finalStep = `<li>Jiki evaluated <code>${leftRes} ${op} ${rightRes}</code> and determined it was <code>${result.jikiObject}</code>.</li>`
  return [...leftSteps, ...rightSteps, finalStep]
}
