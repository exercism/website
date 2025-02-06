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
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { SetVariableStatement } from '../statement'
import { describeCallExpression } from './describeCallStatement'
import { describeLogicalExpression } from './describeIfStatement'
import { describeLiteralExpression } from './describeLiteralExpression'
import { describeExpression, describeSteps } from './describeSteps'
import { appendFullStopIfAppropriate, deepTrim } from './helpers'

export function describeSetVariableStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as SetVariableStatement
  const frameResult = frame.result as EvaluationResultSetVariableStatement

  const name = frameContext.name.lexeme
  const value = formatLiteral(frameResult.resultingValue)

  const result = `<p> This created a new variable called <code>${name}</code> and set its value to <code>${value}</code>.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
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
