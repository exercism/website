import { EvaluationResultReturnStatement } from '../evaluation-result'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { ReturnStatement } from '../statement'
import { describeExpression } from './describeSteps'

const finalStep = `<li>Jiki cleared up and left the function.</li>`

export function describeReturnStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ReturnStatement

  if (frameContext.expression === null) {
    return describeNakedReturn()
  } else {
    return describeReturnWithValue(frame, context)
  }
}

function describeNakedReturn() {
  const result = `<p>This ended the function. No further code was run in the function.</p>`
  const steps = [finalStep]
  return {
    result: result,
    steps: steps,
  }
}

function describeReturnWithValue(
  frame: FrameWithResult,
  context: DescriptionContext
) {
  const frameContext = frame.context as ReturnStatement
  const frameResult = frame.result as EvaluationResultReturnStatement

  const value = formatLiteral(frameResult.resultingValue)
  const result = `<p>This returned <code>${value}</code> and ended the function. No further code was run in the function.</p>`

  let steps = describeExpression(
    frameContext.expression!,
    frameResult.expression!,
    context
  )
  steps = [
    ...steps,
    `<li>Jiki put <code>${value}</code> in the return chute.</li>`,
    finalStep,
  ]

  return {
    result: result,
    steps: steps,
  }
}
