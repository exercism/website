import { toSentence } from '@/utils/toSentence'
import { EvaluationResultCallStatement } from '../evaluation-result'
import { CallExpression } from '../expression'
import { DescriptionContext, FrameWithResult } from '../frames'
import { codeTag, formatLiteral } from '../helpers'
import { CallStatement } from '../statement'
import { describeExpression } from './describeSteps'

export function describeCallStatement(
  frame: FrameWithResult,
  context: DescriptionContext
) {
  const frameContext = frame.context as CallStatement
  const frameResult = frame.result as EvaluationResultCallStatement
  const expression = frameContext.expression as CallExpression

  const fnName = expression.callee.name.lexeme

  const args = ((args) => {
    return toSentence(
      args.map((arg, idx) =>
        codeTag(
          formatLiteral(arg.resultingValue),
          frameContext.expression.args[idx].location
        )
      )
    )
  })(frameResult.expression.args)

  const argsDesc = args.length > 0 ? ` with the inputs ${args}` : ''
  const result = `<p>This used the ${codeTag(
    fnName,
    expression.callee.location
  )} function${argsDesc}.</p>`

  let steps = describeExpression(
    frameContext.expression,
    frameResult.expression,
    context
  )

  return {
    result: result,
    steps: steps,
  }
}

/*
export function describeCallExpression(
  expression: CallExpression,
  result: EvaluationResultCallExpression
  // functionDescriptions: any
) {
  console.log(result)
  const fnName = result.callee.name
  return `\`${fnName}()\``
}

export function describeCallExpression(
  expression: CallExpression,
  result: EvaluationResultCallExpression,
  functionDescriptions: any
) {

  function args() { 
    const argsValues = result.args.map((arg) => arg.value).join(', ')
    return argsValues
  }

  let output = `<p class="mb-8">This called the <code>${result.callee.name}</code> function`
  if (result.args.length > 0) {
    output += ` with the values (${args()})`
  }
  output += `.</p>`
  const descriptionTemplate =
    functionDescriptions[result.callee.name] || ''
  const argsValues = result.args.map((arg) => arg.value)
  const interpolatedDescription = descriptionTemplate.replace(
    /\${arg(\d+)}/g,
    (_, resultingValue) => argsValues[resultingValue - 1].toString() || ''
  )
  output += interpolatedDescription
  return output
}*/
