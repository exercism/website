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

  const args = ((args) => {
    return args.map((arg) => arg.resultingValue).join(', ')
  })(result.args)

  const fnName = result.callee.name
  const fnDesc = generateFunctionDescription(fnName, args, result, context)
  const fnCallDesc = args.length > 0 ? `${fnName}(${args})` : `${fnName}()`

  return [
    ...steps,
    `<li>Jiki used the <code>${fnCallDesc}</code> function${fnDesc}.</li>`,
  ]
}

function generateFunctionDescription(
  fnName: string,
  args: string,
  result: any,
  context: DescriptionContext
) {
  let fnDesc: string = context.functionDescriptions
    ? context.functionDescriptions[fnName] || ''
    : ''

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
