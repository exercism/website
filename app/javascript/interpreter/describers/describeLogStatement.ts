import { EvaluationResultLogStatement } from '../evaluation-result'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { formatJikiObject } from '../helpers'
import { LogStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeLogStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const logStatement = frame.context as LogStatement
  const frameResult = frame.result as EvaluationResultLogStatement
  const value = formatJikiObject(frameResult.jikiObject)

  const result = `<p> This logged <code>${value}</code>.</p>`
  let steps = describeExpression(
    logStatement.expression,
    frameResult.expression,
    context
  )
  steps = [...steps, `<li>Jiki wrote <code>${value}</code> here for you!</li>`]

  return {
    result,
    steps,
  }
}
