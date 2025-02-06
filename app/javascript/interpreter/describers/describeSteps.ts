import { func, string } from 'prop-types'
import {
  EvaluationResult,
  EvaluationResultBinaryExpression,
  EvaluationResultCallExpression,
  EvaluationResultGroupingExpression,
  EvaluationResultLogicalExpression,
} from '../evaluation-result'
import {
  Expression,
  VariableLookupExpression,
  LiteralExpression,
  GroupingExpression,
  BinaryExpression,
  LogicalExpression,
  CallExpression,
} from '../expression'
import { formatLiteral } from '../helpers'
import { describeLogicalExpression } from './describeLogicalExpression'
import { DescriptionContext } from '../frames'
import { fn } from 'jquery'

export function describeExpression(
  expression: Expression,
  result: EvaluationResult,
  context: DescriptionContext
): String[] {
  if (expression instanceof BinaryExpression) {
    return describeBinaryExpression(expression, result, context)
  }
  if (expression instanceof LogicalExpression) {
    return describeLogicalExpression(expression, result, context)
  }
  if (expression instanceof GroupingExpression) {
    return describeGroupingExpression(expression, result, context)
  }
  if (expression instanceof CallExpression) {
    return describeCallExpression(expression, result, context)
  }

  /*if (expression instanceof VariableLookupExpression) {
    return describeVariableExpression(expression, result)
  }
  if (expression instanceof LiteralExpression) {
    return describeLiteralExpression(expression, result)
  }
  if (expression instanceof BinaryExpression) {
    return describeBinaryExpression(expression, result)
  }*/
  return []
}

export function describeCallExpression(
  expression: CallExpression,
  result: EvaluationResultCallExpression,
  context: DescriptionContext
) {
  let steps = expression.args
    .map((arg, idx) => describeExpression(arg, result.args[idx], context))
    .flat()
  const fnName = result.callee.name

  const args = ((args) => {
    return args.map((arg) => arg.resultingValue).join(', ')
  })(result.args)

  const fnCallDesc = args.length > 0 ? `${fnName}(${args})` : `${fnName}()`
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
  return [
    ...steps,
    `<li>Jiki used the <code>${fnCallDesc}</code> function${fnDesc}.</li>`,
  ]
}

export function describeBinaryExpression(
  expression: BinaryExpression,
  result: EvaluationResultBinaryExpression,
  context: DescriptionContext
) {
  const leftSteps = describeExpression(expression.left, result.left, context)
  const rightSteps = describeExpression(expression.right, result.right, context)

  const finalStep = `<li>Jiki evaluated <code>${result.left.resultingValue} ${expression.operator.lexeme} ${result.right.resultingValue}</code> and determined it was <code>${result.resultingValue}</code>.</li>`
  return [...leftSteps, ...rightSteps, finalStep]
}

export function describeGroupingExpression(
  expression: GroupingExpression,
  result: EvaluationResultGroupingExpression,
  context: DescriptionContext
) {
  return describeExpression(expression.inner, result.inner, context)
}
