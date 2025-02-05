import { LogicalExpression } from '../expression'

export function describeLogicalExpression(
  expression: LogicalExpression
): string {
  const left = describeExpression(expression.left)
  const right = describeExpression(expression.right)

  if (expression.operator.type == 'AND') {
    return `both of these were true:</p><ul><li>${left}</li><li>${right}</li></ul><p>`
  } else {
    return `$${left} and ${right} were true`
  }
}
