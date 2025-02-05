import { Description, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { LogStatement } from '../statement'
import { describeSteps } from './describeSteps'

export function describeLogStatement(frame: FrameWithResult): Description {
  const logStatement = frame.context as LogStatement
  const value = formatLiteral(frame.result.value.value)

  const result = `<p> This logged <code>${value}</code>.</p>`
  let steps = describeSteps(logStatement.expression, frame.result.value)
  steps = [...steps, `<li>Jiki wrote <code>${value}</code> here for you!</li>`]

  return {
    result,
    steps,
  }
}
