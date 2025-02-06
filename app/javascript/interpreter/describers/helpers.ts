export function deepTrim(str: string): string {
  return str
    .split('\n')
    .map((l) => l.trim())
    .join('\n')
    .trim()
}

export function addOrdinalSuffix(number) {
  let lastDigit = number % 10,
    lastTwoDigits = number % 100
  if (lastDigit === 1 && lastTwoDigits !== 11) {
    return number + 'st'
  }
  if (lastDigit === 2 && lastTwoDigits !== 12) {
    return number + 'nd'
  }
  if (lastDigit === 3 && lastTwoDigits !== 13) {
    return number + 'rd'
  }
  return number + 'th'
}

export function appendFullStopIfAppropriate(html): string {
  // If we're after a </p> or </ul> then this will already have
  // been handled deeper in the code so just return the input
  // If the string already ends with a full stop, return the input
  if (deepTrim(html).match(/<\/(p|ul)>$/) || deepTrim(html).endsWith('.')) {
    return html
  }

  return `${html}.`
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

function ordinal_suffix_of(i) {
  let j = i % 10,
    k = i % 100
  if (j === 1 && k !== 11) {
    return i + 'st'
  }
  if (j === 2 && k !== 12) {
    return i + 'nd'
  }
  if (j === 3 && k !== 13) {
    return i + 'rd'
  }
  return i + 'th'
}
