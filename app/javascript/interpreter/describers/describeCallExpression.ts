import { EvaluationResultCallExpression } from '../evaluation-result'
import { CallExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { formatLiteral } from '../helpers'
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
    result,
    fnName,
    argNames,
    result,
    context
  )
  const fnCallDesc =
    argNames.length > 0 ? `${fnName}(${argNames})` : `${fnName}()`

  return [
    ...steps,
    `<li>Jiki used the <code>${fnCallDesc}</code> function${fnDesc}.</li>`,
  ]
}

function generateFunctionDescription(
  restul: EvaluationResultCallExpression,
  fnName: string,
  argNames: string,
  result: any,
  context: DescriptionContext
) {
  const descriptionTemplate = context.functionDescriptions
    ? context.functionDescriptions[fnName] || ''
    : ''
  const argsValues = result.args.map(
    (arg) => `<code>${formatLiteral(arg.resultingValue)}</code>`
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
    fnDesc += `returned <code>${value}</code>`
  } else if (fnDesc) {
    fnDesc = `, which ${fnDesc}`
  }
  return fnDesc
}
