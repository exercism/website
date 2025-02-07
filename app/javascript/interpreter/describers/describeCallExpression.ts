import { EvaluationResultCallExpression } from '../evaluation-result'
import { CallExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatLiteral } from '../helpers'
import { describeExpression } from './describeSteps'

export function describeCallExpression(
  expression: CallExpression,
  result: EvaluationResultCallExpression,
  context: DescriptionContext
) {
  let steps = expression.args
    .map((arg, idx) => describeExpression(arg, result.args[idx], context))
    .flat()

  const argNames = ((args) => {
    return args.map((arg) => formatLiteral(arg.resultingValue)).join(', ')
  })(result.args)

  const fnName = result.callee.name
  const fnDesc = generateFunctionDescription(
    expression,
    result,
    fnName,
    argNames,
    context
  )
  const fnCallDesc =
    argNames.length > 0 ? `${fnName}(${argNames})` : `${fnName}()`

  return [
    ...steps,
    `<li>Jiki used the ${codeTag(
      fnCallDesc,
      expression.location
    )} function${fnDesc}.</li>`,
  ]
}

function generateFunctionDescription(
  expression: CallExpression,
  result: EvaluationResultCallExpression,
  fnName: string,
  argNames: string,
  context: DescriptionContext
) {
  const descriptionTemplate = context.functionDescriptions
    ? context.functionDescriptions[fnName] || ''
    : ''
  const argsValues = result.args.map((arg) =>
    codeTag(formatLiteral(arg.resultingValue), expression.location)
  )
  let fnDesc = descriptionTemplate.replace(
    /\${arg(\d+)}/g,
    (_, index) => argsValues[index - 1].toString() || ''
  )

  if (result.resultingValue !== null && result.resultingValue !== undefined) {
    if (fnDesc) {
      fnDesc = `, which ${fnDesc}. It `
    } else {
      fnDesc = `, which `
    }
    const value = formatLiteral(result.resultingValue)
    fnDesc += `returned ${codeTag(value, expression.location)}`
  } else if (fnDesc) {
    fnDesc = `, which ${fnDesc}`
  }
  return fnDesc
}
