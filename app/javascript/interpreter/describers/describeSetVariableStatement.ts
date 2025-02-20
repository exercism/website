import { EvaluationResultSetVariableStatement } from '../evaluation-result'

import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { SetVariableStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeSetVariableStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as SetVariableStatement
  const frameResult = frame.result as EvaluationResultSetVariableStatement

  const name = frameContext.name.lexeme
  const value = formatJikiObject(frameResult.jikiObject)

  const result = `<p>This created a new variable called ${codeTag(
    name,
    frameContext.name.location
  )} and set its value to ${codeTag(value, frameContext.value.location)}.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  steps = [
    ...steps,
    `<li>Jiki created a new box called ${codeTag(
      name,
      frameContext.name.location
    )}.</li>`,
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
