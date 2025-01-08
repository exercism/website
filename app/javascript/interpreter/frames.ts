import { type Callable } from './functions'
import { RuntimeError } from './error'

export type FrameExecutionStatus = 'SUCCESS' | 'ERROR'
import type { EvaluationResult } from './evaluation-result'
import type { ExternalFunction } from './executor'
import { BinaryExpression, Expression } from './expression'

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

function describeIfStatement(frame: FrameWithResult) {
  // TODO!!
  return ''
  // let output = `<p>This checks to see whether <code>${frame.result.condition.left.obj.expression}</code> is greater than <code>${frame.result.condition.right.name}</code>.</p>`
  // output += `<p>In this case, <code>${frame.result.condition.left.obj.expression}</code> is set to <code>${frame.result.condition.left.obj.value}</code> and <code>${frame.result.condition.right.name}</code> is set to <code>${frame.result.condition.right.value}</code> so the result is <code>${frame.result.value}</code>.</p>`
  // return output
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
    (_, index) => argsValues[index - 1] || ''
  )
  output += interpolatedDescription
  return output
}
