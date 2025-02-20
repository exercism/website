import { EvaluationResultChangeVariableStatement } from '../evaluation-result'

import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatLiteral } from '../helpers'
import { ChangeVariableStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeChangeVariableStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangeVariableStatement
  const frameResult = frame.result as EvaluationResultChangeVariableStatement

  const name = frameContext.name.lexeme
  const oldValue = formatLiteral(frameResult.oldValue)
  const value = formatLiteral(frameResult.jikiObject)

  const result = `<p>This changed the value in <code>${name}</code> to <code>${value}</code>.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  steps = [
    ...steps,
    `<li>Jiki found the ${codeTag(name, frameContext.name.location)} box.</li>`,
    `<li>Jiki removed the existing contents (<code>${oldValue}</code>) from the box.</li>`,
    `<li>Jiki put ${codeTag(
      value,
      frameContext.value.location
    )} in the box.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
