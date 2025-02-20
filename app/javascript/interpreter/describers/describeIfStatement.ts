import { EvaluationResultIfStatement } from '../evaluation-result'

import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { IfStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeIfStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const ifStatement = frame.context as IfStatement
  const result = frame.result as EvaluationResultIfStatement

  let steps = describeExpression(
    ifStatement.condition,
    result.condition,
    context
  )
  steps = [...steps, describeFinalStep(result)]

  return {
    result: describeResult(result),
    steps,
  }
}

function describeFinalStep(result: EvaluationResultIfStatement) {
  if (result.jikiObject.value == true) {
    return `<li>The result was <code>true</code> so Jiki decided to run the if block.</li>`
  } else {
    return `<li>The result was <code>false</code> so Jiki decided to skip the if block.</li>`
  }
}

function describeResult(result: EvaluationResultIfStatement) {
  if (result.jikiObject.value == true) {
    return `<p>The condition evaluated to <code>true</code> so the code block ran.</p>`
  } else {
    return `<p>The condition evaluated to <code>false</code> so the code block did not run.</p>`
  }
}
