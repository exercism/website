import { EvaluationResult } from '../evaluation-result'
import {
  Expression,
  GroupingExpression,
  BinaryExpression,
  LogicalExpression,
  FunctionCallExpression,
  VariableLookupExpression,
} from '../expression'
import { describeLogicalExpression } from './describeLogicalExpression'
import { DescriptionContext } from '../frames'
import { describeBinaryExpression } from './describeBinaryExpression'
import { describeFunctionCallExpression } from './describeFunctionCallExpression'
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
  if (expression instanceof FunctionCallExpression) {
    return describeFunctionCallExpression(expression, result, context)
  }
  if (expression instanceof VariableLookupExpression) {
    return describeVariableLookupExpression(expression, result, context)
  }

  return []
}
