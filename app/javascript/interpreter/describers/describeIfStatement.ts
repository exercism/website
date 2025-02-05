import {
  EvaluationResult,
  EvaluationResultBinaryExpression,
  EvaluationResultCallExpression,
  EvaluationResultGroupingExpression,
  EvaluationResultLogicalExpression,
} from '../evaluation-result'
import {
  BinaryExpression,
  CallExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  VariableLookupExpression,
} from '../expression'
import { FrameWithResult } from '../frames'
import { formatLiteral } from '../helpers'
import { IfStatement } from '../statement'
import { deepTrim, describeOperator, isEqualityOperator } from './helpers'

export function describeIfStatement(frame: FrameWithResult) {
  const ifStatement = frame.context as IfStatement

  const conditionDescription = describeCondition(
    ifStatement.condition,
    frame.result.condition
  )

  return deepTrim(`
    <p>This checked whether ${conditionDescription}</p>
    <p>The result was <code>${frame.result.value}</code>.</p>
  `)
}

function describeCondition(
  expression: Expression,
  result: any // ConditionResult
): string {
  if (expression instanceof GroupingExpression) {
    return describeCondition(expression.inner, result.inner)
  }
  if (expression instanceof LiteralExpression) {
    const desc = describeExpression(expression, result)
    return `${desc} was <code>true</code>`
  }
  if (expression instanceof CallExpression) {
    const desc = describeCallExpression(expression, result)
    return `${desc} was <code>true</code>`
  }
  if (expression instanceof LogicalExpression) {
    describeLogicalExpression(expression, result)
  }
  return describeExpression(expression, result)
}

function describeBinaryExpression(
  expression: BinaryExpression,
  result: EvaluationResultBinaryExpression
): string {
  if (expression instanceof BinaryExpression) {
    const left = describeExpression(expression.left, result.left)
    const right = describeExpression(expression.right, result.right)

    if (expression.right instanceof LiteralExpression) {
      return `${left} was ${right}`
    }

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

function describeLiteralExpression(expression, _) {
  return `<code>${formatLiteral(expression.value)}</code>`
}

function describeVariableExpression(expression, _) {
  return expression.description()
}

export function describeLogicalExpression(
  expression: LogicalExpression,
  result: EvaluationResultLogicalExpression
): string {
  const left = describeCondition(expression.left, result.left)

  // TODO: Add test coverage
  if (result.right == null) {
    return `${left}. Checking the right side was skipped.`
  } else {
    const conjuction = expression.operator.type == 'AND' ? 'both' : 'either'
    const right = describeCondition(expression.right, result.right)

    return `${conjuction} of these were true:
    <ul>
      <li>${left}</li>
      <li>${right}</li>
    </ul>
    `
  }
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
  return `the value returned from <code>${fnDesc}</code>`
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
  if (expression instanceof CallExpression) {
    return describeCallExpression(expression, result)
  }
  throw new Error(`Unhandled expression type: ${expression.type}`)
}
