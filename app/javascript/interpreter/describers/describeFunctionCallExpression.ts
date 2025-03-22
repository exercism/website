import { EvaluationResultFunctionCallExpression } from '../evaluation-result'
import { FunctionCallExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { describeExpression } from './describeSteps'

export function describeFunctionCallExpression(
  expression: FunctionCallExpression,
  result: EvaluationResultFunctionCallExpression,
  context: DescriptionContext
) {
  let steps = expression.args
    .map((arg, idx) => describeExpression(arg, result.args[idx], context))
    .flat()

  const argNames = ((args) => {
    return args.map((arg) => formatJikiObject(arg.jikiObject)).join(', ')
  })(result.args)

  const fnName = result.callee.name
  const fnDesc = generateFunctionDescription(
    expression,
    result,
    fnName,
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
  expression: FunctionCallExpression,
  result: EvaluationResultFunctionCallExpression,
  fnName: string,
  context: DescriptionContext
) {
  const descriptionTemplate = context.functionDescriptions
    ? context.functionDescriptions[fnName] || ''
    : ''
  const argsValues = result.args.map((arg) =>
    codeTag(formatJikiObject(arg.jikiObject), expression.location)
  )
  let fnDesc = descriptionTemplate.replace(
    /\${arg(\d+)}/g,
    (_, index) => argsValues[index - 1].toString() || ''
  )

  if (result.jikiObject !== null && result.jikiObject !== undefined) {
    if (fnDesc) {
      fnDesc = `, which ${fnDesc}. It `
    } else {
      fnDesc = `, which `
    }
    const value = formatJikiObject(result.jikiObject)
    fnDesc += `returned ${codeTag(value, expression.location)}`
  } else if (fnDesc) {
    fnDesc = `, which ${fnDesc}`
  }
  return fnDesc
}
