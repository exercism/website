import { EvaluationResultMethodCallExpression } from '../evaluation-result'
import { MethodCallExpression } from '../expression'
import { DescriptionContext } from '../frames'
import { codeTag, formatJikiObject } from '../helpers'
import { describeExpression } from './describeSteps'

export function describeMethodCallExpression(
  expression: MethodCallExpression,
  result: EvaluationResultMethodCallExpression,
  context: DescriptionContext
) {
  const argSteps = expression.args
    .map((arg, idx) => describeExpression(arg, result.args[idx], context))
    .flat()
  const objectSteps = describeExpression(
    expression.object,
    result.object,
    context
  )

  const argNames = ((args) => {
    return args.map((arg) => formatJikiObject(arg.jikiObject)).join(', ')
  })(result.args)

  const methodName = expression.methodName.lexeme
  const fnDesc = generateMethodDescription(
    expression,
    result,
    methodName,
    context
  )
  const fnCallDesc =
    argNames.length > 0 ? `${methodName}(${argNames})` : `${methodName}()`

  const actionCodeTag = codeTag(fnCallDesc, expression.location)
  const who =
    expression.object.type === 'ThisExpression'
      ? "this object's"
      : "the object's"
  const actionStep = `<li>Jiki used ${who} ${actionCodeTag} method${fnDesc}.</li>`

  return [...argSteps, ...objectSteps, ...[actionStep]]
}

function generateMethodDescription(
  expression: MethodCallExpression,
  result: EvaluationResultMethodCallExpression,
  fnName: string,
  context: DescriptionContext
) {
  const descriptionTemplate = result.method.description
  const argsValues = result.args.map((arg) =>
    codeTag(formatJikiObject(arg.jikiObject), expression.location)
  )
  let fnDesc = descriptionTemplate
    ? descriptionTemplate.replace(
        /\${arg(\d+)}/g,
        (_, index) => argsValues[index - 1].toString() || ''
      )
    : null

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
