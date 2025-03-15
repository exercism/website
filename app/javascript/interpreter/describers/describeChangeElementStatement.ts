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
  const frameContext = frame.context as ChangeElementStatement
  const frameResult = frame.result as EvaluationResultChangeElementStatement

  if (frame.result.object.jikiObject instanceof Jiki.List) {
    return describeChangeElementStatementList(
      frameContext,
      frameResult,
      context
    )
  } else {
    return describeChangeElementStatementDictionary(
      frameContext,
      frameResult,
      context
    )
  }
}

function describeChangeElementStatementList(
  frameContext: ChangeElementStatement,
  frameResult: EvaluationResultChangeElementStatement,
  context: DescriptionContext
): Description {
  const idx = frameResult.field.jikiObject?.value
  const ordinaledIndex = addOrdinalSuffix(idx)

  const oldValue = formatJikiObject(frameResult.oldValue)
  const value = formatJikiObject(frameResult.value.jikiObject)
  const valueCodeTag = codeTag(value, frameContext.value.location)

  let dictDescription = 'the list'
  let boxStep: string | undefined

  if (frameContext.object.type == 'VariableLookupExpression') {
    const object = frameContext.object as VariableLookupExpression
    const variableName = object.name.lexeme
    const variableCodeTag = codeTag(variableName, frameContext.object.location)
    dictDescription = `the ${variableCodeTag} list`
    boxStep = `<li>Jiki found the ${variableCodeTag} box.</li>`
  }

  const result = `<p>This changed the value in the ${ordinaledIndex} element of ${dictDescription} to ${valueCodeTag}.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)
  steps = [
    ...steps,
    ...([boxStep].filter(Boolean) as string[]),
    `<li>Jiki removed the existing contents (<code>${oldValue}</code>) from the ${ordinaledIndex} slot of the list.</li>`,
    `<li>Jiki put ${valueCodeTag} in the ${ordinaledIndex} slot of the list.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}

function describeChangeElementStatementDictionary(
  frameContext: ChangeElementStatement,
  frameResult: EvaluationResultChangeElementStatement,
  context: DescriptionContext
): Description {
  let dictDescription = 'the dictionary'
  let boxStep: string | undefined

  if (frameContext.object.type == 'VariableLookupExpression') {
    const object = frameContext.object as VariableLookupExpression
    const variableName = object.name.lexeme
    const variableCodeTag = codeTag(variableName, frameContext.object.location)
    dictDescription = `the ${variableCodeTag} dictionary`
    boxStep = `<li>Jiki found the ${variableCodeTag} box.</li>`
  }

  const key = frameResult.field.jikiObject
  const value = formatJikiObject(frameResult.value.jikiObject)
  const keyCodeTag = codeTag(key, frameContext.field.location)
  const valueCodeTag = codeTag(value, frameContext.value.location)

  if (frameResult.oldValue == undefined) {
    return describeChangeElementStatementDictionaryAddKey(
      frameContext,
      frameResult,
      context,
      dictDescription,
      boxStep,
      keyCodeTag,
      valueCodeTag
    )
  }
  return describeChangeElementStatementDictionaryUpdateKey(
    frameContext,
    frameResult,
    context,
    dictDescription,
    boxStep,
    keyCodeTag,
    valueCodeTag
  )
}

function describeChangeElementStatementDictionaryAddKey(
  frameContext: ChangeElementStatement,
  frameResult: EvaluationResultChangeElementStatement,
  context: DescriptionContext,
  dictDescription: string,
  boxStep: string | undefined,
  keyCodeTag: string,
  valueCodeTag: string
): Description {
  const result = `<p>This added a new key/value pair to ${dictDescription}, with the key of ${keyCodeTag} and the value of ${valueCodeTag}.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)

  steps = [
    ...steps,
    ...([boxStep].filter(Boolean) as string[]),
    `<li>Jiki checked for the ${keyCodeTag} key in the dictionary and saw it was missing.</li>`,
    `<li>Jiki add a new key value pair with the key of ${keyCodeTag} and the value of ${valueCodeTag}.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
function describeChangeElementStatementDictionaryUpdateKey(
  frameContext: ChangeElementStatement,
  frameResult: EvaluationResultChangeElementStatement,
  context: DescriptionContext,
  dictDescription: string,
  boxStep: string | undefined,
  keyCodeTag: string,
  valueCodeTag: string
): Description {
  const result = `<p>This changed the value of the key ${keyCodeTag} in ${dictDescription} to ${valueCodeTag}.</p>`
  let steps = describeExpression(frameContext.value, frameResult.value, context)

  steps = [
    ...steps,
    ...([boxStep].filter(Boolean) as string[]),
    `<li>Jiki found the ${keyCodeTag} key in the dictionary.</i>`,
    `<li>Jiki updated the corresponding value to be ${valueCodeTag}.</li>`,
  ]

  return {
    result: result,
    steps: steps,
  }
}
