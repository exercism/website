import { formatLiteral } from '../helpers'

export function describeLiteralExpression(expression) {
  return `<code>${formatLiteral(expression.value)}</code>`
}
