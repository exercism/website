import { InterpretResult } from '@/interpreter/interpreter'

function wasFunctionUsed(
  result: InterpretResult,
  name: string,
  args: any[] | null,
  times?: number
): boolean {
  let timesCalled
  const fnCalls = result.meta.getFunctionCallLog()

  if (fnCalls[name] === undefined) {
    timesCalled = 0
  } else if (args !== null && args !== undefined) {
    timesCalled = fnCalls[name][JSON.stringify(args)]
  } else {
    timesCalled = Object.values(fnCalls[name]).reduce((acc, count) => {
      return acc + count
    }, 0)
  }

  if (times === null || times === undefined) {
    return timesCalled >= 1
  }
  return timesCalled === times
}

function getAddedLineCount(
  result: InterpretResult,
  stubLines: number = 0
): number {
  const lines = result.meta
    .getSourceCode()
    .split('\n')
    .filter((l) => l.trim() !== '' && !l.startsWith('//'))

  return lines.length - stubLines
}

export default {
  wasFunctionUsed,
  getAddedLineCount,
}
