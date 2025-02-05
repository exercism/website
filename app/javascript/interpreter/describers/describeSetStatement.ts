import {
  EvaluationResult,
  EvaluationResultSetVariableStatement,
} from '../evaluation-result'
import {
  Expression,
  VariableLookupExpression,
  LiteralExpression,
  GroupingExpression,
  BinaryExpression,
  LogicalExpression,
  CallExpression,
} from '../expression'
import { Description, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { SetVariableStatement } from '../statement'
import { describeCallExpression } from './describeCallExpression'
import { describeLogicalExpression } from './describeIfStatement'
import { describeLiteralExpression } from './describeLiteralExpression'
import { describeSteps } from './describeSteps'
import { appendFullStopIfAppropriate, deepTrim } from './helpers'

export function describeSetVariableStatement(
  frame: FrameWithResult
): Description {
  const context = frame.context as SetVariableStatement
  const frameResult = frame.result as EvaluationResultSetVariableStatement

  const name = context.name.lexeme
  const value = formatLiteral(frameResult.value.value)
  // let value = describeExpression(context.initializer, result.value)
  // value = appendFullStopIfAppropriate(value)

  const result = `<p> This created a new variable called <code>${name}</code> and set its value to <code>${value}</code>.  </p>`
  let steps = describeSteps(context.initializer, frameResult.value)
  steps = [
    ...steps,
    `<li>Jiki created a new box called <code>${name}</code>.</li>`,
    `<li>Jiki put <code>${value}</code> in the box.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}

function describeExpression(
  expression: Expression,
  result: EvaluationResult
): string {
  if (expression instanceof LiteralExpression) {
    return describeLiteralExpression(expression, result)
  }
  if (expression instanceof LogicalExpression) {
    return describeLogicalExpression(expression, result)
  }
  if (expression instanceof CallExpression) {
    return describeCallExpression(expression, result)
  }
  // if (expression instanceof VariableLookupExpression) {
  //   return describeVariableExpression(expression, result)
  // }
  // if (expression instanceof GroupingExpression) {
  //   return describeGroupingExpression(expression, result)
  // }
  // if (expression instanceof BinaryExpression) {
  //   return describeBinaryExpression(expression, result)
  // }
  throw new Error(`Unhandled expression type: ${expression.type}`)
}
