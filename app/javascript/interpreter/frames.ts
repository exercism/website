import { type Callable } from './functions'
import { RuntimeError } from './error'

export type FrameExecutionStatus = 'SUCCESS' | 'ERROR'
import type {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
  EvaluationResultIfStatement,
} from './evaluation-result'
import type { ExternalFunction } from './executor'
import {
  BinaryExpression,
  CallExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  VariableLookupExpression,
} from './expression'
import {
  IfStatement,
  SetVariableStatement,
  Statement,
  ChangeVariableStatement,
  ReturnStatement,
  LogStatement,
} from './statement'
import { describeIfStatement } from './describers/describeIfStatement'
import { marked } from 'marked'
import { describeSetVariableStatement } from './describers/describeSetVariableStatement'
import { describeLogStatement } from './describers/describeLogStatement'
import { deepTrim } from './describers/helpers'
import { describeChangeVariableStatement } from './describers/describeChangeStatement'
import { describeCallStatement } from './describers/describeCallStatement'

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

export type Description = {
  result: String
  steps: String[]
}

export type DescriptionContext = {
  functionDescriptions: Record<string, string>
}

function isFrameWithResult(frame: Frame): frame is FrameWithResult {
  return !!frame.result
}

const defaultMessage = `<p>There is no information available for this line. Show us your code in Discord and we'll improve this!</p>`

export function describeFrame(
  frame: Frame,
  context?: DescriptionContext
): string {
  if (!isFrameWithResult(frame)) {
    return defaultMessage
  }
  if (context == null) {
    context = { functionDescriptions: {} }
  }

  let description: Description | null = null
  try {
    description = generateDescription(frame, context)
  } catch (e) {
    if (process.env.NODE_ENV != 'production') {
      throw e
    }
    return defaultMessage
  }
  if (description == null) {
    return defaultMessage
  }

  return deepTrim(`
  <h3>What happened</h3>
  ${description.result}
  <hr/>
  <h3>Steps Jiki Took</h3>
  <ul>
    ${description.steps.join('\n')}
  </ul>
  `)
}

function generateDescription(
  frame: FrameWithResult,
  context: DescriptionContext
): Description | null {
  switch (frame.result.type) {
    case 'LogStatement':
      return describeLogStatement(frame, context)

    case 'SetVariableStatement':
      return describeSetVariableStatement(frame, context)
    case 'ChangeVariableStatement':
      return describeChangeVariableStatement(frame, context)

    case 'CallStatement':
      return describeCallStatement(frame, context)
    // case 'ReturnStatement':
    //   return describeReturnStatement(frame)

    case 'IfStatement':
      return describeIfStatement(frame, context)
  }
  return null
}
/*
      // case 'ForeachStatement':
      //   return describeForeachStatement(frame)
      // default:
    // } catch (e) {
    //  return `<p>There is no information available for this line. Show us your code in Discord and we'll improve this!</p>`


/*
    // These need to come from the exercise.
    const functionDescriptions: Record<string, string> =
      externalFunctions.reduce(
        (acc: Record<string, string>, fn: ExternalFunction) => {
          acc[fn.name] = fn.description
          return acc
        },
        {}
      )

    if (!isFrameWithResult(frame)) {
      return '<p>There is no information available for this line.</p>'
    }
    let description = ''
    switch (frame.result.type) {
      case 'SetVariableStatement':
        return describeSetVariableStatement(frame)
      case 'ForeachStatement':
        return describeForeachStatement(frame)
      case 'ChangeVariableStatement':
        return describeChangeVariableStatement(frame)
      case 'IfStatement':
        return describeIfStatement(frame)
      case 'LogStatement':
        return describeLogStatement(frame)
      case 'ReturnStatement':
        return describeReturnStatement(frame)
      case 'CallExpression':
        return describeCallExpression(frame, functionDescriptions)
      default:
        return `<p>There is no information available for this line. Show us your code in Discord and we'll improve this!</p>`
    }
    // } catch (e) {
    //  return `<p>There is no information available for this line. Show us your code in Discord and we'll improve this!</p>`
  } finally {
  }
}

function addExtraAssignInfo(frame: Frame, output: string) {
  if (frame.result?.value == null) {
    output +=
      '<p><code>null</code> is a special keyword that signifies the lack of a real value. It is often used as a placeholder before we know what we should set a value to.</p>'
  }

  return output
}

function describeChangeVariableStatement(frame: FrameWithResult): string {
  if (!frame.context === null) {
    return ''
  }
  if (!(frame.context instanceof ChangeVariableStatement)) {
    return ''
  }

  return frame.context.description(
    frame.result as EvaluationResultChangeVariableStatement
  )
}

function describeForeachStatement(result: EvaluationResult) {
  let output = `<p>This looped through <code>${result.iterable.name}</code> array. Each time this line of code is run, it selects the next item from the array and assigns to the <code>${frame.result.elementName}</code> variable.</p>`

  if (result.value) {
    output += `<p>This iteration set <code>${result.elementName}</code> to:</p>`
    output += `<pre><code>${JSON.stringify(result.value, null, 2)}</code></pre>`
  }

  return output
}

function describeExpression(expression: Expression, result?: EvaluationResult) {
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

function describeReturnStatement(frame: FrameWithResult) {
  const context = frame.context as ReturnStatement
  if (context === undefined) {
    return ''
  }
  return context.description(frame.result)
}
*/
