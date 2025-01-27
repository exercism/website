export function formatLiteral(value?: any): string {
  if (value === undefined) {
    return ''
  }

  if (typeof value === 'string') {
    return `"${value}"`
  }
  return value.toString()
}
