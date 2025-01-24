import { FunctionCallTypeMismatchError } from './error'
import { ExecutionContext, ExternalFunction } from './executor'

export const StdlibFunctions: Record<string, ExternalFunction> = {
  join: {
    name: 'join',
    func: join,
    description: 'Joins two strings together',
  },
}

function join(_: ExecutionContext, str1: string, str2: string) {
  verifyType(str1, 'string', 1)
  verifyType(str2, 'string', 2)

  return `${str1}${str2}`
}

function verifyType(arg: any, type: 'string', argIdx: number) {
  if (typeof arg !== type) {
    throw new FunctionCallTypeMismatchError({
      argIdx,
      expectedType: type,
      actualType: typeof arg,
    })
  }
}
