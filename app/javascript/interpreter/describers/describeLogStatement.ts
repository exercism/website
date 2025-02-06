import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { LogStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeLogStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const logStatement = frame.context as LogStatement
  const value = formatLiteral(frame.result.value.value)

  const result = `<p> This logged <code>${value}</code>.</p>`
  let steps = describeExpression(
    logStatement.expression,
    frame.result.value,
    context
  )
  steps = [...steps, `<li>Jiki wrote <code>${value}</code> here for you!</li>`]

  return {
    result,
    steps,
  }
}
