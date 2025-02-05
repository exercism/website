import {
  EvaluationResult,
  EvaluationResultGroupingExpression,
  EvaluationResultIfStatement,
} from '../evaluation-result'
import {
  BinaryExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  VariableLookupExpression,
} from '../expression'
import { FrameWithResult } from '../frames'
import { IfStatement } from '../statement'
import { describeCallExpression } from './describeCallExpression'
import { deepTrim, describeOperator, isEqualityOperator } from './helpers'

export function describeIfStatement(frame: FrameWithResult) {
  const ifStatement = frame.context as IfStatement

  const conditionDescription = describeCondition(
    ifStatement.condition,
    frame.result.condition
  )

  return deepTrim(`
    This checked whether ${conditionDescription}

    The result was \`${frame.result.value}\`.
  `)
}

function describeCondition(
  expression: Expression,
  result: any // ConditionResult
): string {
  if (expression.type === 'CallExpression') {
    const desc = describeCallExpression(expression, result)
    return `${desc} returned \`true\``
  } else {
    return describeExpression(expression, result)
  }
}

function describeOperator(operator: string): string {
  switch (operator) {
    case 'GREATER':
      return 'greater than'
    case 'LESS':
      return 'less than'
    case 'GREATER_EQUAL':
      return 'greater than or equal to'
    case 'LESS_EQUAL':
      return 'less than or equal to'
    case 'EQUALITY':
      return 'equal to'
    case 'INEQUALITY':
      return 'not equal to'
    case 'MINUS':
      return 'minus'
  }

  return ''
}

function describeBinaryExpression(expression: BinaryExpression): string {
  if (expression instanceof BinaryExpression) {
    const left = describeExpression(expression.left)
    const right = describeExpression(expression.right)
    const operator = describeOperator(expression.operator.type)
    if (isEqualityOperator(expression.operator.type)) {
      return `${left} was ${operator} ${right}`
    } else {
      return `${left} ${operator} ${right}`
    }
  }
  return ''
}

function describeGroupingExpression(
  expression: GroupingExpression,
  result: EvaluationResultGroupingExpression
): string {
  return describeExpression(expression.inner, result.inner)
}

function describeBinaryExpression(expression: BinaryExpression): string {
  if (expression instanceof BinaryExpression) {
    const left = describeExpression(expression.left)
    const right = describeExpression(expression.right)
    const operator = describeOperator(expression.operator.type)
    if (isEqualityOperator(expression.operator.type)) {
      return `${left} was ${operator} ${right}`
    } else {
      return `${left} ${operator} ${right}`
    }
  }
  return ''
}

function describeLiteralExpression(expression, _) {
  return expression.description()
}

function describeVariableExpression(expression, _) {
  return expression.description()
}

function describeExpression(
  expression: Expression,
  result: EvaluationResult
): string {
  if (expression instanceof VariableLookupExpression) {
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
  }
  if (expression instanceof LogicalExpression) {
    return describeLogicalExpression(expression, result)
  }
  throw new Error(`Unhandled expression type: ${expression.type}`)
}
