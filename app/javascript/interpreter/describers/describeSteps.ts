import { string } from 'prop-types'
import {
  EvaluationResult,
  EvaluationResultBinaryExpression,
  EvaluationResultCallExpression,
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
import { describeLogicalExpression } from './steps/describeLogicalExpression'

export function describeSteps(
  expression: Expression,
  result: EvaluationResult
): String[] {
  return describeExpression(expression, result)
}

export function describeExpression(
  expression: Expression,
  result: EvaluationResult
): String[] {
  if (expression instanceof BinaryExpression) {
    return describeBinaryExpression(expression, result)
  }
  if (expression instanceof LogicalExpression) {
    return describeLogicalExpression(expression, result)
  }

  /*if (expression instanceof VariableLookupExpression) {
    return describeVariableExpression(expression, result)
  }
  if (expression instanceof LiteralExpression) {
    return describeLiteralExpression(expression, result)
  }
  if (expression instanceof GroupingExpression) {
    return describeGroupingExpression(expression, result)
  }
  if (expression instanceof BinaryExpression) {
    return describeBinaryExpression(expression, result)
  }*/
  if (expression instanceof CallExpression) {
    return describeCallExpression(expression, result)
  }
  return []
}

export function describeCallExpression(
  expression: CallExpression,
  result: EvaluationResultCallExpression
) {
  const fnName = result.callee.name

  const args = ((args) => {
    return args.map((arg) => arg.value).join(', ')
  })(result.args)

  const fnDesc = args.length > 0 ? `${fnName}(${args})` : `${fnName}()`
  const value = formatLiteral(result.value)
  return [
    `<li>Jiki used the <code>${fnDesc}</code> function, which returned <code>${value}</code>.</li>`,
  ]
}

export function describeBinaryExpression(
  expression: BinaryExpression,
  result: EvaluationResultBinaryExpression
) {
  const leftSteps = describeExpression(expression.left, result.left)
  const rightSteps = describeExpression(expression.right, result.right)

  const finalStep = `<li>Jiki evaluated <code>${result.left.value} ${expression.operator.lexeme} ${result.right.value}</code> and determined it was <code>${result.value}</code>.</li>`
  return [...leftSteps, ...rightSteps, finalStep]
}
