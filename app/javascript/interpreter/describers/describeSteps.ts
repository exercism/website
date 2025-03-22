import {
  EvaluationResult,
  EvaluationResultBinaryExpression,
  EvaluationResultFunctionCallExpression,
  EvaluationResultGroupingExpression,
  EvaluationResultInstantiationExpression,
  EvaluationResultLogicalExpression,
  EvaluationResultMethodCallExpression,
  EvaluationResultUnaryExpression,
  EvaluationResultVariableLookupExpression,
} from '../evaluation-result'
import {
  Expression,
  GroupingExpression,
  BinaryExpression,
  LogicalExpression,
  FunctionCallExpression,
  VariableLookupExpression,
  InstantiationExpression,
  AccessorExpression,
  UnaryExpression,
  MethodCallExpression,
} from '../expression'
import { describeLogicalExpression } from './describeLogicalExpression'
import { DescriptionContext } from '../frames'
import { describeBinaryExpression } from './describeBinaryExpression'
import { describeFunctionCallExpression } from './describeFunctionCallExpression'
import { describeGroupingExpression } from './describeGroupingExpression'
import { describeVariableLookupExpression } from './describeVariableLookupExpression'
import { describeInstantiationExpression } from './describeInstantiationExpression'
import { describeGetterExpression } from './describeGetterExpression'
import { describeUnaryExpression } from './describeUnaryExpression'
import { describeMethodCallExpression } from './describeMethodCallExpression'

export function describeExpression(
  expression: Expression,
  result: EvaluationResult,
  context: DescriptionContext
): String[] {
  if (expression instanceof BinaryExpression) {
    return describeBinaryExpression(
      expression,
      result as EvaluationResultBinaryExpression,
      context
    )
  }
  if (expression instanceof LogicalExpression) {
    return describeLogicalExpression(
      expression,
      result as EvaluationResultLogicalExpression,
      context
    )
  }
  if (expression instanceof GroupingExpression) {
    return describeGroupingExpression(
      expression,
      result as EvaluationResultGroupingExpression,
      context
    )
  }
  if (expression instanceof FunctionCallExpression) {
    return describeFunctionCallExpression(
      expression,
      result as EvaluationResultFunctionCallExpression,
      context
    )
  }
  if (expression instanceof MethodCallExpression) {
    return describeMethodCallExpression(
      expression,
      result as EvaluationResultMethodCallExpression,
      context
    )
  }
  if (expression instanceof VariableLookupExpression) {
    return describeVariableLookupExpression(
      expression,
      result as EvaluationResultVariableLookupExpression,
      context
    )
  }
  if (expression instanceof InstantiationExpression) {
    return describeInstantiationExpression(
      expression,
      result as EvaluationResultInstantiationExpression,
      context
    )
  }
  if (expression instanceof UnaryExpression) {
    return describeUnaryExpression(
      expression,
      result as EvaluationResultUnaryExpression,
      context
    )
  }
  if (expression instanceof AccessorExpression) {
    if (result.type == 'GetterExpression') {
      return describeGetterExpression(expression, result, context)
    } else {
      //return describeSetterExpression(expression, result, context)
    }
  }

  return []
}
