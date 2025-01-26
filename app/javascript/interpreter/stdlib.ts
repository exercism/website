import { FunctionCallTypeMismatchError } from './error'
import { ExecutionContext, ExternalFunction } from './executor'

export function filteredStdLibFunctions(required: string[]) {
  // Choose the functions that are available to the student from config.stdlibFunctions
  return Object.entries(StdlibFunctions)
    .filter(([key]) => (required || []).includes(key))
    .map(([_, v]) => v)
}

const StdlibFunctions: Record<string, ExternalFunction> = {
  join: {
    name: 'join',
    func: join,
    description: 'Joins two strings together',
  },
  number_to_string: {
    name: 'number_to_string',
    func: numberToString,
    description: 'Converts a number to a string',
  },
}

function join(_: ExecutionContext, str1: string, str2: string) {
  verifyType(str1, 'string', 1)
  verifyType(str2, 'string', 2)

  return `${str1}${str2}`
}

function numberToString(_: ExecutionContext, num: number) {
  verifyType(num, 'number', 1)

  return num.toString()
}

function verifyType(arg: any, type: 'string' | 'number', argIndex: number) {
  if (typeof arg !== type) {
    throw new FunctionCallTypeMismatchError({
      argIndex,
      expectedType: type,
      actualType: typeof arg,
    })
  }
}
