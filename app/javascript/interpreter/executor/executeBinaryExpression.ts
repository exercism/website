import { isArray, isNumber } from 'lodash'
import {
  EvaluationResult,
  EvaluationResultExpression,
} from '../evaluation-result'
import { Executor } from '../executor'
import { BinaryExpression } from '../expression'

export function executeBinaryExpression(
  executor: Executor,
  expression: BinaryExpression
): EvaluationResult {
  const leftResult = executor.evaluate(expression.left)
  const rightResult = executor.evaluate(expression.right)

  guardLists(executor, expression, leftResult, rightResult)
  const result: EvaluationResult = {
    type: 'BinaryExpression',
    left: leftResult,
    right: rightResult,
    resultingValue: handleExpression(
      executor,
      expression,
      leftResult,
      rightResult
    ),
  }
  return result
}

function handleExpression(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  switch (expression.operator.type) {
    case 'INEQUALITY':
      return handle_inequality(executor, expression, leftResult, rightResult)
    case 'EQUALITY':
      return handle_equality(executor, expression, leftResult, rightResult)
    case 'GREATER':
      return handle_greater(executor, expression, leftResult, rightResult)
    case 'GREATER_EQUAL':
      return handle_greater_equal(executor, expression, leftResult, rightResult)
    case 'LESS':
      return handle_less(executor, expression, leftResult, rightResult)
    case 'LESS_EQUAL':
      return handle_less_equal(executor, expression, leftResult, rightResult)
    case 'MINUS':
      return handle_minus(executor, expression, leftResult, rightResult)
    case 'PLUS':
      return handle_plus(executor, expression, leftResult, rightResult)
    case 'SLASH':
      return handle_slash(executor, expression, leftResult, rightResult)
    case 'STAR':
      return handle_star(executor, expression, leftResult, rightResult)
    case 'PERCENT':
      return handle_percent(executor, expression, leftResult, rightResult)
    case 'EQUAL':
      executor.error('UnexpectedEqualsForEquality', expression.location, {
        expression,
      })
    default:
      executor.error('InvalidBinaryExpression', expression.location, {
        expression,
      })
  }
}

function handle_inequality(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  return leftResult.resultingValue !== rightResult.resultingValue
}

function handle_equality(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  return leftResult.resultingValue === rightResult.resultingValue
}

function handle_greater(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  return leftResult.resultingValue > rightResult.resultingValue
}

function handle_greater_equal(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  return leftResult.resultingValue >= rightResult.resultingValue
}

function handle_less(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  return leftResult.resultingValue < rightResult.resultingValue
}

function handle_less_equal(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  return leftResult.resultingValue <= rightResult.resultingValue
}

function handle_minus(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  const minusValue = leftResult.resultingValue - rightResult.resultingValue
  return Math.round(minusValue * 100) / 100
}

function handle_plus(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  const plusValue = leftResult.resultingValue + rightResult.resultingValue
  return Math.round(plusValue * 100) / 100
}

function handle_slash(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  const slashValue = leftResult.resultingValue / rightResult.resultingValue
  return Math.round(slashValue * 100) / 100
}

function handle_star(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  const starValue = leftResult.resultingValue * rightResult.resultingValue
  return Math.round(starValue * 100) / 100
}

function handle_percent(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
): any {
  executor.verifyNumber(leftResult.resultingValue, expression.left)
  executor.verifyNumber(rightResult.resultingValue, expression.right)
  return leftResult.resultingValue % rightResult.resultingValue
}

function guardLists(
  executor: Executor,
  expression: BinaryExpression,
  leftResult: EvaluationResultExpression,
  rightResult: EvaluationResultExpression
) {
  if (
    isArray(leftResult.resultingValue) &&
    isArray(rightResult.resultingValue)
  ) {
    executor.error('ListsCannotBeCompared', expression.location)
  }
}
