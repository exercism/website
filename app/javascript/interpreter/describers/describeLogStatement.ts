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
import { FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { LogStatement, SetVariableStatement } from '../statement'
import { describeCallExpression } from './describeCallExpression'
import { describeLogicalExpression } from './describeIfStatement'
import { describeLiteralExpression } from './describeLiteralExpression'
import { describeSteps } from './describeSteps'
import { deepTrim } from './helpers'

export function describeLogStatement(frame: FrameWithResult) {
  const logStatement = frame.context as LogStatement
  const value = formatLiteral(frame.result.value.value)

  const steps = describeSteps(logStatement.expression, frame.result.value).join(
    '\n'
  )
  // let value = describeExpression(context.initializer, result.value)
  // value = appendFullStopIfAppropriate(value)

  return deepTrim(`
    <p> This logged <code>${value}</code>.</p>
    <hr/>
    <h3>Steps Jiki Took</h3>
    <ul>
      ${steps}
      <li>Jiki wrote <code>${value}</code> here for you!</li>
    </ul>
  `)
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
