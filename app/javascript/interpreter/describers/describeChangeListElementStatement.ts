import { EvaluationResultChangeListElementStatement } from '../evaluation-result'
import { VariableLookupExpression } from '../expression'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { ChangeListElementStatement } from '../statement'
import { describeExpression } from './describeSteps'
import { addOrdinalSuffix } from './helpers'

export function describeChangeListElementStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangeListElementStatement
  const frameResult = frame.result as EvaluationResultChangeListElementStatement

  const idx = frameResult.index.resultingValue
  const ordinaledIndex = addOrdinalSuffix(idx)

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

  const result = `<p>This changed the value in the ${ordinaledIndex} element of ${listDescription} to <code>${value}</code>.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  if (boxStep) {
    steps.push(boxStep)
  }
  steps = [
    ...steps,
    `<li>Jiki removed the existing contents (<code>${oldValue}</code>) from the ${ordinaledIndex} slot of the list.</li>`,
    `<li>Jiki put <code>${value}</code> in the ${ordinaledIndex} slot of the list.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
