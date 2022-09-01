import pluralize from 'pluralize'

export function pluralizeWithNumber(
  number: number,
  word: string,
  isUncountable = false
): string {
  return `${number} ${pluralize(word, number, isUncountable)}`
}
