import {
  EvaluationResult,
  EvaluationResultChangeElementStatement,
} from '../evaluation-result'
import { VariableLookupExpression } from '../expression'
import { Description, DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { ChangeElementStatement } from '../statement'
import { describeExpression } from './describeSteps'
import { addOrdinalSuffix } from './helpers'
import * as Jiki from '../jikiObjects'

export function describeChangeElementStatement(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  if (frame.result.object.jikiObject instanceof Jiki.List) {
    return describeChangeElementStatementList(frame, context)
  } else {
    return describeChangeElementStatementDictionary(frame, context)
  }
}

function describeChangeElementStatementList(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangeElementStatement
  const frameResult = frame.result as EvaluationResultChangeElementStatement

  const idx = frameResult.field.jikiObject?.value
  const ordinaledIndex = addOrdinalSuffix(idx)

  const oldValue = formatJikiObject(frameResult.oldValue)
  const value = formatJikiObject(frameResult.value.jikiObject)

  let boxStep
  let dictDescription

  if (frameContext.object.type == 'VariableLookupExpression') {
    const variableName = (frameContext.object as VariableLookupExpression).name
      .lexeme
    ;(boxStep = `<li>Jiki found the ${codeTag(
      variableName,
      frameContext.object.location
    )} box.</li>`),
      (dictDescription = `the ${codeTag(
        variableName,
        frameContext.object.location
      )} list`)
  } else {
    dictDescription = `the list`
  }

  ;[boxStep].flat()

  const result = `<p>This changed the value in the ${ordinaledIndex} element of ${dictDescription} to ${codeTag(
    value,
    frameContext.value.location
  )}.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  if (boxStep) {
    steps.push(boxStep)
  }
  steps = [
    ...steps,
    `<li>Jiki removed the existing contents (<code>${oldValue}</code>) from the ${ordinaledIndex} slot of the list.</li>`,
    `<li>Jiki put ${codeTag(
      value,
      frameContext.value.location
    )} in the ${ordinaledIndex} slot of the list.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}

function describeChangeElementStatementDictionary(
  frame: FrameWithResult,
  context: DescriptionContext
): Description {
  const frameContext = frame.context as ChangeElementStatement
  const frameResult = frame.result as EvaluationResultChangeElementStatement

  const key = frameResult.field.jikiObject
  const value = formatJikiObject(frameResult.value.jikiObject)

  let boxStep
  let dictDescription

  if (frameContext.object.type == 'VariableLookupExpression') {
    const variableName = (frameContext.object as VariableLookupExpression).name
      .lexeme
    ;(boxStep = `<li>Jiki found the ${codeTag(
      variableName,
      frameContext.object.location
    )} box.</li>`),
      (dictDescription = `the ${codeTag(
        variableName,
        frameContext.object.location
      )} dictionary`)
  } else {
    dictDescription = `the dictionary`
  }

  ;[boxStep].flat()

  const result = `<p>This changed the value of the key ${codeTag(
    key,
    frameContext.field.location
  )} in ${dictDescription} to ${codeTag(
    value,
    frameContext.value.location
  )}.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  if (boxStep) {
    steps.push(boxStep)
  }
  steps = [
    ...steps,
    `<li>Jiki found the ${codeTag(
      key,
      frameContext.field.location
    )} key in the dictionary.</i>`,
    `<li>Jiki updated the corresponding value to be ${codeTag(
      value,
      frameContext.value.location
    )}.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
