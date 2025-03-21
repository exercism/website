import {
  EvaluationResultFullyEvaluatedLogicalExpression,
  EvaluationResultLogicalExpression,
  EvaluationResultUnaryExpression,
} from '../evaluation-result'
import { LogicalExpression, UnaryExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { describeExpression } from './describeSteps'
import * as Jiki from '../jikiObjects'

export function describeUnaryExpression(
  expression: UnaryExpression,
  result: EvaluationResultUnaryExpression,
  context: DescriptionContext
) {
  if (expression.operator.type == 'NOT') {
    return describeNotExpression(expression, result, context)
  }
  if (expression.operator.type == 'MINUS') {
    return describeMinusExpression(expression, result, context)
  }
  return []
}

function describeNotExpression(
  expression: UnaryExpression,
  result: EvaluationResultUnaryExpression,
  context: DescriptionContext
) {
  const resBool = result.operand.jikiObject as Jiki.Boolean
  let steps = describeExpression(expression.operand, result.operand, context)
  steps = [
    ...steps,
    `<li>Jiki evaluated that ${codeTag(
      `not ${resBool}`,
      expression.operand.location
    )} is ${codeTag(result.jikiObject, expression.location)}.</li>`,
  ]
  return steps
}

function describeMinusExpression(
  expression: UnaryExpression,
  result: EvaluationResultUnaryExpression,
  context: DescriptionContext
) {
  // If this is a negative number, there's no steps to show.
  if (expression.operand.type == 'LiteralExpression') {
    return []
  }
  const resNum = result.operand.jikiObject as Jiki.Number
  let steps = describeExpression(expression.operand, result.operand, context)
  steps = [
    ...steps,
    `<li>Jiki evaluated that ${codeTag(
      `-${resNum}`,
      expression.operand.location
    )} is ${codeTag(result.jikiObject, expression.location)}.</li>`,
  ]
  return steps
}
