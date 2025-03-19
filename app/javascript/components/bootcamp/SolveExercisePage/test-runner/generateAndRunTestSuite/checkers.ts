import {
  Expression,
  FunctionCallExpression,
  BinaryExpression,
  LiteralExpression,
} from '@/interpreter/expression'
import { InterpretResult } from '@/interpreter/interpreter'
import { Statement } from '@/interpreter/statement'

function numFunctionCalls(
  result: InterpretResult,
  name: string,
  args: any[] | null
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
  return extractFunctionCallExpressions(result.meta.statements).filter(
    (expr) => {
      return expr.callee.name.lexeme === fnName
    }
  ).length
}

function numStatements(result: InterpretResult): number {
  console.log(result.meta.statements)
  return result.meta.statements.length
}

function numTimesStatementUsed(result: InterpretResult, type: string): number {
  const filterStatements = (statements) =>
    statements
      .filter((obj) => obj)
      .map((elem: Statement | Expression) => {
        if (elem.type == type) {
          return [elem]
        }
        return filterStatements(elem.children())
      })
      .flat()

  return filterStatements(result.meta.statements).length
}

function numDirectStringComparisons(result: InterpretResult): number {
  const binaryExpressions = extractExpressions(
    result.meta.statements,
    BinaryExpression
  )
  return binaryExpressions.filter(
    (expr) =>
      (expr.operator.type === 'EQUAL_EQUAL' &&
        expr.left.type === 'Literal' &&
        expr.right.type === 'Literal' &&
        typeof (expr.left as LiteralExpression).value === 'string') ||
      typeof (expr.right as LiteralExpression).value === 'string'
  ).length
}

function numUppercaseLettersInStrings(result: InterpretResult): number {
  const literals = extractExpressions(result.meta.statements, LiteralExpression)
  return literals.filter(
    (expr) =>
      typeof expr.value === 'string' && expr.value !== expr.value.toLowerCase()
  ).length
}

export default {
  numFunctionCalls,
  wasFunctionCalled,
  numFunctionCallsInCode,
  numStatements,
  numDirectStringComparisons,
  numTimesStatementUsed,
  numUppercaseLettersInStrings,
  numLinesOfCode,
}

export function extractFunctionCallExpressions(
  tree: Statement[] | Expression[]
): FunctionCallExpression[] {
  return extractExpressions(tree, FunctionCallExpression)
}

export function extractExpressions<T extends Expression>(
  tree: Statement[] | Expression[],
  type: new (...args: any[]) => T
): T[] {
  // Remove null and undefined then map to the subtrees and
  // eventually to the call expressions.
  return tree
    .filter((obj) => obj)
    .map((elem: Statement | Expression) => {
      const res = elem instanceof type ? [elem] : []
      return res.concat(extractExpressions<T>(elem.children(), type))
    })
    .flat()
}
