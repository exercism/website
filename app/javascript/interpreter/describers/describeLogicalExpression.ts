import {
  EvaluationResultFullyEvaluatedLogicalExpression,
  EvaluationResultLogicalExpression,
} from '../evaluation-result'
import { LogicalExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { describeExpression } from './describeSteps'

export function describeLogicalExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression,
  context: DescriptionContext
) {
  return result.shortCircuited
    ? describeShortCircuitedExpression(expression, result, context)
    : describeFullExpression(expression, result, context)
}

function describeShortCircuitedExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression,
  context: DescriptionContext
) {
  let steps = describeExpression(expression.left, result.left, context)
  steps = [
    ...steps,
    `<li>Jiki saw the left side of the <code>${
      expression.operator.lexeme
    }</code> was <code>${formatJikiObject(
      result.left.jikiObject
    )}</code> and so did not bother looking at the right side.</li>`,
  ]
  return steps
}

function describeFullExpression(
  expression: LogicalExpression,
  result: EvaluationResultFullyEvaluatedLogicalExpression,
  context: DescriptionContext
) {
  if (result.right == null) {
    return []
  }
  let inBetweenSteps: string[] = []
  if (expression.left.type === 'LiteralExpression') {
    inBetweenSteps.push(
      `<li>Jiki saw the left side of the ${codeTag(
        expression.operator.lexeme,
        expression.operator.location
      )} was ${codeTag(
        result.left.jikiObject,
        expression.left.location
      )} and so decided to evaluate the right side.</li>`
    )
  }

  return [
    ...describeExpression(expression.left, result.left, context),
    ...inBetweenSteps,
    ...describeExpression(expression.right, result.right, context),
    `<li>Jiki evaluated ${codeTag(
      `${result.left.jikiObject} ${expression.operator.lexeme} ${result.right.jikiObject}`,
      expression.location
    )} and determined the result was ${codeTag(
      result.jikiObject,
      expression.location
    )}.</li>`,
  ]
}
