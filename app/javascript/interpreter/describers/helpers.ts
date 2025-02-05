export function deepTrim(str: string): string {
  return str
    .split('\n')
    .map((l) => l.trim())
    .join('\n')
    .trim()
}

export function describeOperator(operator: string): string {
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

export function isEqualityOperator(operator: string): boolean {
  return [
    'EQUALITY',
    'INEQUALITY',
    'GREATER',
    'LESS',
    'GREATER_EQUAL',
    'LESS_EQUAL',
  ].includes(operator)
}
