export function extractLineAndColumnFromStack(stack?: string): {
  line: number
  column: number
} {
  if (!stack) {
    return { line: 1, column: 1 }
  }

  const match = stack.match(/(?:\()?(?:\w+\.js|<anonymous>):(\d+):(\d+)\)?/)

  if (match) {
    return {
      line: parseInt(match[1], 10),
      column: parseInt(match[2], 10),
    }
  }

  return { line: 1, column: 1 }
}
