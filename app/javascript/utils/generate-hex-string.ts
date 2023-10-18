export function generateHexString(length: number): string {
  let result = ''
  while (result.length < length) {
    result += Math.random().toString(16).slice(2)
  }
  return result.slice(0, length)
}
