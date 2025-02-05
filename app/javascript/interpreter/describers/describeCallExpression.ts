import { EvaluationResultCallExpression } from '../evaluation-result'
import { CallExpression } from '../expression'
import { formatLiteral } from '../helpers'

export function describeCallExpression(
  expression: CallExpression,
  result: EvaluationResultCallExpression
) {
  const fnName = result.callee.name

  const args = ((args) => {
    return args.map((arg) => arg.value).join(', ')
  })(result.args)

  const fnDesc = args.length > 0 ? `${fnName}(${args})` : `${fnName}()`
  return `the value returned from <code>${fnDesc}</code> (<code>${formatLiteral(
    result.value
  )}</code>)`
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
    (_, index) => argsValues[index - 1].toString() || ''
  )
  output += interpolatedDescription
  return output
}*/
