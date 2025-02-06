import {
  EvaluationResult,
  EvaluationResultChangeListElementStatement,
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
import {
  ChangeListElementStatement,
  ChangeVariableStatement,
  SetVariableStatement,
} from '../statement'
import { describeLogicalExpression } from './describeIfStatement'
import { describeLiteralExpression } from './describeLiteralExpression'
import { describeExpression, describeSteps } from './describeSteps'
import {
  addOrdinalSuffix,
  appendFullStopIfAppropriate,
  deepTrim,
} from './helpers'

export function describeChangeListElementStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangeListElementStatement
  const frameResult = frame.result as EvaluationResultChangeListElementStatement

  const name = frameContext.list
  const idx = frameResult.resultingValue
  const oldValue = formatLiteral(frameResult.oldValue)
  const value = formatLiteral(frameResult.resultingValue)

  let boxStep
  let listDescription

  if (frameContext.list.type == 'VariableLookupExpression') {
    const variableName = (frameContext.list as VariableLookupExpression).name
      .lexeme
    ;(boxStep = `<li>Jiki found the <code>${variableName}</code> box.</li>`),
      (listDescription = `the <code>${variableName}</code> list`)
  } else {
    listDescription = `the list`
  }

  ;[boxStep].flat()

  const ordinaledIndex = addOrdinalSuffix(idx.resultingValue)
  const result = `<p>This changed the value in the ${ordinaledIndex} element of ${listDescription} to <code>${value}</code>.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  if (boxStep) {
    steps.push(boxStep)
  }
  steps = [
    ...steps,
    `<li>Jiki remove the existing contents (<code>${oldValue}</code>) from the ${ordinaledIndex} slot of the list.</li>`,
    `<li>Jiki put <code>${value}</code> in the ${ordinaledIndex} slot of the list.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
