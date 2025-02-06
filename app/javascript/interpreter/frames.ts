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
import { describeReturnStatement } from './describers/describeReturnStatement'
import { describeChangeListElementStatement } from './describers/describeChangeListElementStatement'
import { describeForeachStatement } from './describers/describeForeachStatement'

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

    case 'ChangeListElementStatement':
      return describeChangeListElementStatement(frame, context)

    case 'CallStatement':
      return describeCallStatement(frame, context)
    case 'ReturnStatement':
      return describeReturnStatement(frame, context)

    case 'IfStatement':
      return describeIfStatement(frame, context)
    case 'ForeachStatement':
      return describeForeachStatement(frame, context)
  }
  return null
}
