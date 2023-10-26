export function capitalize(word: string): string {
  if (typeof word !== 'string') {
    throw new TypeError("The parameter 'word' must be a string.")
  }

  if (word === '') {
    return ''
  }

  const trimmedWord = word.trim()

  if (trimmedWord === '') {
    return ''
  }

  return (
    trimmedWord.charAt(0).toUpperCase() + trimmedWord.slice(1).toLowerCase()
  )
}
