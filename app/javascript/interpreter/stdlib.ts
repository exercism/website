import { isArray } from './checks'
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
    description: 'joined the two strings together',
  },
  concatenate: {
    name: 'concatenate',
    func: concatenate,
    description: 'concatenated the strings together',
    arity: [2, Infinity],
  },
  push: {
    name: 'push',
    func: push,
    description: 'added an element to the list',
  },
  concat: {
    name: 'concat',
    func: concat,
    description: 'joined the two lists together',
  },
  number_to_string: {
    name: 'number_to_string',
    func: numberToString,
    description: 'converted the number to a string',
  },
  to_upper_case: {
    name: 'to_upper_case',
    func: toUpperCase,
    description: 'converted the string to its uppercase equivalent',
  },
  has_key: {
    name: 'has_key',
    func: hasKey,
    description: 'checked if the object has the key',
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

function push(_: ExecutionContext, list: any[], element: any) {
  verifyType(list, 'list', 1)

  list.push(element)
  return list
}

function concat(_: ExecutionContext, list1: any[], list2: any[]) {
  verifyType(list1, 'list', 1)
  verifyType(list2, 'list', 2)

  return list1.concat(list2)
}

function numberToString(_: ExecutionContext, num: number) {
  verifyType(num, 'number', 1)

  return num.toString()
}

function toUpperCase(_: ExecutionContext, str: string) {
  verifyType(str, 'string', 1)

  return str.toUpperCase()
}

function hasKey(_: ExecutionContext, obj: Record<string, any>, key: string) {
  verifyType(obj, 'object', 1)
  verifyType(key, 'string', 2)

  return obj.hasOwnProperty(key)
}

function verifyType(
  arg: any,
  targetType: 'string' | 'number' | 'list' | 'object',
  argIdx: number
) {
  let argType
  if (isArray(arg)) {
    argType = 'list'
  } else {
    argType = typeof arg
  }
  if (argType !== targetType) {
    throw new FunctionCallTypeMismatchError({
      argIdx,
      expectedType: targetType,
      actualType: typeof arg,
    })
  }
}
