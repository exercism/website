import { EvaluationResult } from '../evaluation-result'
import {
  Expression,
  GroupingExpression,
  BinaryExpression,
  LogicalExpression,
  CallExpression,
  VariableLookupExpression,
} from '../expression'
import { describeLogicalExpression } from './describeLogicalExpression'
import { DescriptionContext } from '../frames'
import { describeBinaryExpression } from './describeBinaryExpression'
import { describeCallExpression } from './describeCallExpression'
import { describeGroupingExpression } from './describeGroupingExpression'
import { describeVariableLookupExpression } from './describeVariableLookupExpression'

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
  if (expression instanceof VariableLookupExpression) {
    return describeVariableLookupExpression(expression, result, context)
  }

  return []
}
