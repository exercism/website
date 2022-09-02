import pluralize from 'pluralize'

export function pluralizeWithNumber(
  number: number,
  word: string,
  isUncountable = false
): string {
  return `${number.toLocaleString()} ${pluralize(word, number, isUncountable)}`
}
