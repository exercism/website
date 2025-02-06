import { isArray } from './checks'
import {
  BinaryExpression,
  CallExpression,
  Expression,
  GroupingExpression,
} from './expression'
import { Statement } from './statement'

export function formatLiteral(value?: any): string {
  if (value === undefined) {
    return ''
  }

  return JSON.stringify(value)
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
