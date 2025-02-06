import {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
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
import { ChangeVariableStatement, SetVariableStatement } from '../statement'
import { describeLogicalExpression } from './describeIfStatement'
import { describeLiteralExpression } from './describeLiteralExpression'
import { describeExpression, describeSteps } from './describeSteps'
import { appendFullStopIfAppropriate, deepTrim } from './helpers'

export function describeChangeVariableStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangeVariableStatement
  const frameResult = frame.result as EvaluationResultChangeVariableStatement

  const name = frameContext.name.lexeme
  const oldValue = formatLiteral(frameResult.oldValue)
  const value = formatLiteral(frameResult.resultingValue)

  const result = `<p>This changed the value in <code>${name}</code> to <code>${value}</code>.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  steps = [
    ...steps,
    `<li>Jiki found the <code>${name}</code> box.</li>`,
    `<li>Jiki remove the existing contents (<code>${oldValue}</code>) from the box.</li>`,
    `<li>Jiki put <code>${value}</code> in the box.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
