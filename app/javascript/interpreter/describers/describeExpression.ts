import { type Callable } from '../functions'
import { RuntimeError } from '../error'

export type FrameExecutionStatus = 'SUCCESS' | 'ERROR'
import type {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
  EvaluationResultIfStatement,
} from '../evaluation-result'
import type { ExternalFunction } from '../executor'
import {
  BinaryExpression,
  CallExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  VariableLookupExpression,
} from '../expression'
import {
  IfStatement,
  SetVariableStatement,
  Statement,
  ChangeVariableStatement,
  ReturnStatement,
  LogStatement,
} from '../statement'

export type FrameType = 'ERROR' | 'REPEAT' | 'EXPRESSION'

export type Frame = {
  line: number
  code: string
  status: FrameExecutionStatus
  error?: RuntimeError
  priorVariables: Record<string, any>
  variables: Record<string, any>
  functions: Record<string, Callable>
  time: number
  result?: EvaluationResult
  data?: Record<string, any>
  description: string
  context?: Statement | Expression
}
export type FrameWithResult = Frame & { result: EvaluationResult }
export function describeExpression(
  expression: Expression,
  result?: EvaluationResult
) {
  if (expression instanceof VariableLookupExpression) {
    return expression.description()
  }
  if (expression instanceof LiteralExpression) {
    return expression.description()
  }
  if (expression instanceof CallExpression) {
    return expression.description(result)
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
  return ''
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

function describeBinaryExpression(
  expression: BinaryExpression,
  result?: EvaluationResult
): string {
  const left = describeExpression(expression.left, result?.left)
  const right = describeExpression(expression.right, result?.right)
  const operator = describeOperator(expression.operator.type)
  if (isEqualityOperator(expression.operator.type)) {
    return `${left} was ${operator} ${right}`
  } else {
    return `${left} ${operator} ${right}`
  }
}

function describeLogicalExpression(
  expression: LogicalExpression,
  result?: EvaluationResult
): string {
  const left = describeExpression(expression.left, result?.left)
  const right = describeExpression(expression.right, result?.right)

  if (expression.operator.type == 'AND') {
    return `both of these were true:</p><ul><li>${left}</li><li>${right}</li></ul><p>`
  } else {
    return `$${left} and ${right} were true`
  }
}

function describeGroupingExpression(
  expression: GroupingExpression,
  result: EvaluationResult
): string {
  return `${describeExpression(expression.inner, result)}`
}

function describeCondition(
  expression: Expression,
  result: EvaluationResultIfStatement
): string {
  return describeExpression(expression, result.condition)
}

function describeCallExpression(
  frame: FrameWithResult,
  functionDescriptions: any
) {
  let output = `<p class="mb-8">This called the <code>${frame.result.callee.name}</code> function`
  if (frame.result.args.length > 0) {
    const argsValues = frame.result.args.map((arg) => arg.value).join(', ')
    output += ` with the values (${argsValues})`
  }
  output += `.</p>`
  const descriptionTemplate =
    functionDescriptions[frame.result.callee.name] || ''
  const argsValues = frame.result.args.map((arg) => arg.value)
  const interpolatedDescription = descriptionTemplate.replace(
    /\${arg(\d+)}/g,
    (_, index) => argsValues[index - 1].toString() || ''
  )
  output += interpolatedDescription
  return output
}

function isEqualityOperator(operator: string): boolean {
  return [
    'EQUALITY',
    'INEQUALITY',
    'GREATER',
    'LESS',
    'GREATER_EQUAL',
    'LESS_EQUAL',
  ].includes(operator)
}
