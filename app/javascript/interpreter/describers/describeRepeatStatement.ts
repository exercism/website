import { isString } from '../checks'
import {
  EvaluationResultForeachStatement,
  EvaluationResultRepeatStatement,
} from '../evaluation-result'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { ForeachStatement, RepeatStatement } from '../statement'
import { describeExpression } from './describeSteps'
import { addOrdinalSuffix } from './helpers'

export function describeRepeatStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as RepeatStatement
  const frameResult = frame.result as EvaluationResultRepeatStatement

  let res
  if (frameResult.count.jikiObject?.value == 0) {
    res = describeNoRepeats(frameContext, frameResult)
  } else {
    res = describeRepeat(frameContext, frameResult)
  }
  return {
    result: res.result,
    steps: [
      ...describeExpression(frameContext.count, frameResult.count, context),
      ...res.steps,
    ],
  }
}
function describeNoRepeats(
  frameContext: RepeatStatement,
  frameResult: EvaluationResultRepeatStatement
): Description {
  const result = `<p>The repeat block was asked to run ${codeTag(
    frameResult.count.jikiObject?.value,
    frameContext.count.location
  )} times so this line did nothing.</p>`
  const steps = [
    `<li>Jiki saw that the loop should be run ${codeTag(
      formatJikiObject(frameResult.count.jikiObject),
      frameContext.count.location
    )} times and so decided not to do anything further on this line.</li>`,
  ]
  return { result, steps }
}

function describeRepeat(
  frameContext: RepeatStatement,
  frameResult: EvaluationResultRepeatStatement
): Description {
  const ordinaledIteration = addOrdinalSuffix(frameResult.iteration)
  const result = `<p>This line started the ${ordinaledIteration} iteration of this repeat block.</p>`
  const steps = [
    `<li>Jiki increased his internal counter for this loop to <code>${
      frameResult.iteration
    }</code>, checked ${codeTag(
      `${frameResult.iteration} &le; ${formatJikiObject(
        frameResult.count.jikiObject
      )}`,
      frameContext.count.location
    )}, and decided to run the code block.</li>`,
  ]
  return { result, steps }
}
