import { type Callable } from './functions'
import { RuntimeError } from './error'

export type FrameExecutionStatus = 'SUCCESS' | 'ERROR'
import type { EvaluationResult } from './evaluation-result'
import type { ExternalFunction } from './executor'
import {
  BinaryExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  VariableExpression,
} from './expression'
import { IfStatement, Statement } from './statement'
import exp from 'constants'

export type FrameType = 'ERROR' | 'REPEAT' | 'EXPRESSION'

export type Frame = {
  line: number
  code: string
  status: FrameExecutionStatus
  error?: RuntimeError
  variables: Record<string, any>
  functions: Record<string, Callable>
  time: number
  result?: EvaluationResult
  data?: Record<string, any>
  description: string
  context?: Statement | Expression
}
export type FrameWithResult = Frame & { result: EvaluationResult }

function isFrameWithResult(frame: Frame): frame is FrameWithResult {
  return !!frame.result
}

export function describeFrame(
  frame: Frame,
  externalFunctions: ExternalFunction[]
): string {
  // These need to come from the exercise.
  const functionDescriptions: Record<string, string> = externalFunctions.reduce(
    (acc: Record<string, string>, fn: ExternalFunction) => {
      acc[fn.name] = fn.description
      return acc
    },
    {}
  )

  if (!isFrameWithResult(frame)) {
    return '<p>There is no information available for this line.</p>'
  }
  switch (frame.result.type) {
    case 'VariableStatement':
      return describeVariableStatement(frame)
    case 'ForeachStatement':
      return describeForeachStatement(frame)
    case 'AssignExpression':
      return describeAssignExpression(frame)
    case 'IfStatement':
      return describeIfStatement(frame)
    case 'ReturnStatement':
      return describeReturnStatement(frame)
    case 'CallExpression':
      return describeCallExpression(frame, functionDescriptions)
    default:
      return `<p>There is no information available for this line.</p>`
  }
}

function addExtraAssignInfo(frame: Frame, output: string) {
  if (frame.result?.value == null) {
    output +=
      '<p><code>null</code> is a special keyword that signifies the lack of a real value. It is often used as a placeholder before we know what we should set a value to.</p>'
  }

  return output
}

function describeVariableStatement(frame: FrameWithResult) {
  let output
  if (frame.result.data?.updating) {
    output = `<p>This updated the <code>${frame.result.name}</code> variable to <code>${frame.result.value}</code>.</p>`
  } else {
    output = `<p>This created a new variable called <code>${frame.result.name}</code> and sets it to be equal to <code>${frame.result.value}</code>.</p>`
  }
  output = addExtraAssignInfo(frame, output)

  return output
}

function describeAssignExpression(frame: FrameWithResult) {
  let output = `<p>This updated the variable called <code>${frame.result.name}</code> to <code>${frame.result.value.value}</code>.</p>`
  output = addExtraAssignInfo(frame, output)

  return output
}

function describeForeachStatement(frame: FrameWithResult) {
  let output = `<p>This looped through <code>${frame.result.iterable.name}</code> array. Each time this line of code is run, it selects the next item from the array and assigns to the <code>${frame.result.elementName}</code> variable.</p>`

  if (frame.result.value) {
    output += `<p>This iteration set <code>${frame.result.elementName}</code> to:</p>`
    output += `<pre><code>${JSON.stringify(
      frame.result.value,
      null,
      2
    )}</code></pre>`
  }

  return output
}

function describeExpression(expression: Expression) {
  if (expression instanceof VariableExpression) {
    return describeVariableExpression(expression)
  }
  if (expression instanceof LiteralExpression) {
    return describeLiteralExpression(expression)
  }
  if (expression instanceof GroupingExpression) {
    return describeGroupingExpression(expression)
  }
  if (expression instanceof BinaryExpression) {
    return describeBinaryExpression(expression)
  }
  if (expression instanceof LogicalExpression) {
    return describeLogicalExpression(expression)
  }
  return ''
}

function describeVariableExpression(expression: VariableExpression): string {
  return `the <code>${expression.name.lexeme}</code> variable`
}

function describeLiteralExpression(expression: LiteralExpression): string {
  let value = expression.value
  if (typeof expression.value === 'string') {
    value = '"' + expression.value + '"'
  }

  return `<code>${value}</code>`
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
    case 'STRICT_EQUALITY':
      return 'equal to'
    case 'STRICT_INEQUALITY':
      return 'not equal to'
  }

  return ''
}

function describeBinaryExpression(expression: BinaryExpression): string {
  if (expression instanceof BinaryExpression) {
    const left = describeExpression(expression.left)
    const right = describeExpression(expression.right)
    const operator = describeOperator(expression.operator.type)
    return `${left} was ${operator} ${right}`
  }
  return ''
}

function describeLogicalExpression(expression: LogicalExpression): string {
  let prefix = ''
  if (expression.operator.type == 'AND') {
    prefix = 'both'
  }
  const left = describeExpression(expression.left)
  const right = describeExpression(expression.right)

  return `${prefix} ${left}, and ${right} were true`
}

function describeGroupingExpression(expression: GroupingExpression): string {
  return describeExpression(expression.inner)
}

function describeCondition(expression: Expression): string {
  return describeExpression(expression)
}

function describeIfStatement(frame: FrameWithResult) {
  const ifStatement = frame.context as IfStatement
  const conditionDescription = describeCondition(ifStatement.condition)
  let output = `
    <p>This checked whether ${conditionDescription}.</p>
    <p>The result was <code>${frame.result.value}</code>.</p>
    `
  return output
}
function describeReturnStatement(frame: FrameWithResult) {
  let output = `<p>This returned the value of <code>${frame.result.value.name}</code>, which in this case is <code>${frame.result.value.value}</code>.</p>`
  return output
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
