import { Expression, CallExpression } from '@/interpreter/expression'
import { InterpretResult } from '@/interpreter/interpreter'
import { Statement } from '@/interpreter/statement'

function numFunctionCalls(
  result: InterpretResult,
  name: string,
  args: any[] | null,
  times?: number
): number {
  const fnCalls = result.meta.functionCallLog

  if (fnCalls[name] === undefined) {
    return 0
  }

  if (args !== null && args !== undefined) {
    return fnCalls[name][JSON.stringify(args)]
  }

  return Object.values(fnCalls[name]).reduce((acc, count) => {
    return acc + count
  }, 0)
}

function wasFunctionCalled(
  result: InterpretResult,
  name: string,
  args: any[] | null,
  times?: number
): boolean {
  return numFunctionCalls(result, name, args, times) >= 1
}

function numLinesOfCode(
  result: InterpretResult,
  numStubLines: number = 0
): number {
  const lines = result.meta.sourceCode
    .split('\n')
    .filter((l) => l.trim() !== '' && !l.startsWith('//'))

  return lines.length - numStubLines
}

function numFunctionCallsInCode(
  result: InterpretResult,
  fnName: string
): number {
  return extractCallExpressions(result.meta.statements).filter(
    (expr) => expr.callee.name.lexeme === fnName
  ).length
}

export default {
  numFunctionCalls,
  wasFunctionCalled,
  numFunctionCallsInCode,
  numLinesOfCode,
}

export function extractCallExpressions(
  tree: Statement[] | Expression[]
): CallExpression[] {
  // Remove null and undefined then map to the subtrees and
  // eventually to the call expressions.
  return tree
    .filter((obj) => obj)
    .map((elem: Statement | Expression) => {
      if (elem instanceof CallExpression) {
        return [elem]
      }
      return extractCallExpressions(elem.children())
    })
    .flat()
}
