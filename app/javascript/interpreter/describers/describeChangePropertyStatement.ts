import {
  EvaluationResult,
  EvaluationResultChangeElementStatement,
  EvaluationResultChangePropertyStatement,
} from '../evaluation-result'
import { VariableLookupExpression } from '../expression'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { ChangeElementStatement, ChangePropertyStatement } from '../statement'
import { describeExpression } from './describeSteps'
import { addOrdinalSuffix } from './helpers'

export function describeChangePropertyStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangePropertyStatement
  const frameResult = frame.result as EvaluationResultChangePropertyStatement

  const objectSteps = describeExpression(
    frameContext.object,
    frameResult.object,
    context
  )
  const valueSteps = describeExpression(
    frameContext.value,
    frameResult.value,
    context
  )
  const resultingValue = frameResult.value.jikiObject

  const steps = [
    ...objectSteps,
    ...valueSteps,
    `<li>Jiki set the ${codeTag(
      frameContext.property.lexeme,
      frameContext.property.location
    )} property to ${codeTag(
      resultingValue,
      frameContext.value.location
    )}.</li>`,
  ]
  const result = `<p>This set the <code>${frameContext.property.lexeme}</code> property to <code>${resultingValue}</code>.</p>`

  return {
    result: result,
    steps: steps,
  }
}
