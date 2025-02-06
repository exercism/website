import { isString } from '../checks'
import { EvaluationResultForeachStatement } from '../evaluation-result'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { ForeachStatement } from '../statement'
import { addOrdinalSuffix } from './helpers'

export function describeForeachStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ForeachStatement
  const frameResult = frame.result as EvaluationResultForeachStatement

  if (frameResult.iterable.resultingValue.length === 0) {
    return describeEmptyList(frameResult)
  } else {
    return describePopulatedList(frameResult)
  }
}
function describeEmptyList(
  frameResult: EvaluationResultForeachStatement
): Description {
  const type = isString(frameResult.iterable.resultingValue) ? 'string' : 'list'
  const result = `<p>The ${type} was empty so this line did nothing.</p>`
  const steps = [
    `<li>Jiki checked the ${type}, saw it was empty, and decided not to do anything further on this line.</li>`,
  ]
  return {
    result,
    steps,
  }
}

function describePopulatedList(
  frameResult: EvaluationResultForeachStatement
): Description {
  const name = frameResult.temporaryVariableName
  const value = formatLiteral(frameResult.temporaryVariableValue)
  const ordinaledIndex = addOrdinalSuffix(frameResult.index)
  const result = `<p>This line started the ${ordinaledIndex} iteration with the <code>${name}</code> variable set to <code>${value}</code>.</p>`
  const steps = [
    `<li>Jiki created a new box called <code>${name}</code>.</li>`,
    `<li>Jiki put <code>${value}</code> in the box, and put it on the shelf, ready to use in the code block.</li>`,
  ]
  return {
    result,
    steps,
  }
}
