import { InterpretResult } from '@/interpreter/interpreter'

export function wasFunctionUsed(
  result: InterpretResult,
  name: string,
  args: any[] | null,
  times?: number
): boolean {
  let timesCalled
  const fnCalls = result.functionCallLog

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
