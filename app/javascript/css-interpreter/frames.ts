import { RuntimeError } from './error'

export type FrameExecutionStatus = 'SUCCESS' | 'ERROR'
import type { EvaluationResult } from './evaluation-result'

import { Statement } from './statement'

export type FrameType = 'ERROR' | 'REPEAT' | 'EXPRESSION'

export type Animation = {
  selector: string
  property: string
  value: string | number | boolean
}
export type Frame = {
  line: number
  code: string
  status: FrameExecutionStatus
  error?: RuntimeError
  time: number
  timelineTime: number
  animations: Animation[]
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

export function framesSucceeded(frames: Frame[]): boolean {
  return frames.every((frame) => frame.status === 'SUCCESS')
}
export function framesErrored(frames: Frame[]): boolean {
  return !framesSucceeded(frames)
}

export function describeFrame(
  frame: Frame,
  context?: DescriptionContext
): string {
  return ''

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

    case 'ChangeElementStatement':
      return describeChangeElementStatement(frame, context)

    case 'FunctionCallStatement':
      return describeFunctionCallStatement(frame, context)
    case 'ReturnStatement':
      return describeReturnStatement(frame, context)

    case 'IfStatement':
      return describeIfStatement(frame, context)
    case 'ForeachStatement':
      return describeForeachStatement(frame, context)
    case 'RepeatStatement':
      return describeRepeatStatement(frame, context)
    case 'BreakStatement':
      return describeBreakStatement(frame, context)
    case 'NextStatement':
      return describeNextStatement(frame, context)
    case 'ChangePropertyStatement':
      return describeChangePropertyStatement(frame, context)
  }
  return null
}
