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
  concatenate: {
    name: 'concatenate',
    func: concatenate,
    description: 'Concatenates multiple strings together',
    arity: [2, Infinity],
  },
  number_to_string: {
    name: 'number_to_string',
    func: numberToString,
    description: 'Converts a number to a string',
  },
  to_upper_case: {
    name: 'to_upper_case',
    func: toUpperCase,
    description: 'Converts a string to its uppercase equivelent',
  },
}

function join(_: ExecutionContext, str1: string, str2: string) {
  verifyType(str1, 'string', 1)
  verifyType(str2, 'string', 2)

  return `${str1}${str2}`
}

function concatenate(_: ExecutionContext, ...strings) {
  strings.forEach((str, idx) => verifyType(str, 'string', idx + 1))
  return strings.join('')
}

function numberToString(_: ExecutionContext, num: number) {
  verifyType(num, 'number', 1)

  return num.toString()
}

function toUpperCase(_: ExecutionContext, str: string) {
  verifyType(str, 'string', 1)

  return str.toUpperCase()
}

function verifyType(arg: any, type: 'string' | 'number', argIdx: number) {
  if (typeof arg !== type) {
    throw new FunctionCallTypeMismatchError({
      argIdx,
      expectedType: type,
      actualType: typeof arg,
    })
  }
}
