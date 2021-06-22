export function toSentence(arr: string[]): string {
  if (arr.length === 1) {
    return arr[0]
  }

  const last = arr.pop()

  return `${arr.join(', ')} and ${last}`
}
