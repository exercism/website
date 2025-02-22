import { isArray } from './checks'
import { FunctionCallTypeMismatchError } from './error'
import { ExecutionContext, ExternalFunction } from './executor'
import * as Jiki from './jikiObjects'

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
  to_lower_case: {
    name: 'to_lower_case',
    func: toLowerCase,
    description: 'converted the string to its lowercase equivalent',
  },
  has_key: {
    name: 'has_key',
    func: hasKey,
    description: 'checked if the object has the key',
  },
  keys: {
    name: 'keys',
    func: keys,
    description: 'retrieved the keys of the dictionary',
  },
}

function join(
  _: ExecutionContext,
  str1: Jiki.String,
  str2: Jiki.String
): Jiki.String {
  verifyType(str1, Jiki.String, 'string', 1)
  verifyType(str2, Jiki.String, 'string', 2)

  return new Jiki.String(`${str1.value}${str2.value}`)
}

function concatenate(
  _: ExecutionContext,
  ...strings: Jiki.String[]
): Jiki.String {
  strings.forEach((str, idx) => verifyType(str, Jiki.String, 'string', idx + 1))
  return new Jiki.String(strings.map((str) => str.value).join(''))
}

function push(
  _: ExecutionContext,
  list: Jiki.List,
  element: Jiki.JikiObject
): Jiki.List {
  verifyType(list, Jiki.List, 'list', 1)

  list.value.push(element)
  return list
}

function concat(
  _: ExecutionContext,
  list1: Jiki.List,
  list2: Jiki.List
): Jiki.List {
  verifyType(list1, Jiki.List, 'list', 1)
  verifyType(list2, Jiki.List, 'list', 2)

  return new Jiki.List(list1.value.concat(list2.value))
}

function numberToString(_: ExecutionContext, num: Jiki.Number): Jiki.String {
  verifyType(num, Jiki.Number, 'number', 1)

  return new Jiki.String(num.value.toString())
}

function toUpperCase(_: ExecutionContext, str: Jiki.String): Jiki.String {
  verifyType(str, Jiki.String, 'string', 1)

  return new Jiki.String(str.value.toUpperCase())
}

function toLowerCase(_: ExecutionContext, str: Jiki.String): Jiki.String {
  verifyType(str, Jiki.String, 'string', 1)

  return new Jiki.String(str.value.toLowerCase())
}

function hasKey(
  _: ExecutionContext,
  dict: Jiki.Dictionary,
  key: Jiki.String
): Jiki.Boolean {
  verifyType(dict, Jiki.Dictionary, 'dictionary', 1)
  verifyType(key, Jiki.String, 'string', 2)

  return new Jiki.Boolean(dict.value.has(key.value))
}

function keys(_: ExecutionContext, dict: Jiki.Dictionary): Jiki.List {
  verifyType(dict, Jiki.Dictionary, 'dictionary', 1)

  return new Jiki.List(
    Array.from(dict.value.keys() as IterableIterator<string>).map(
      (key: string) => new Jiki.String(key)
    )
  )
}

function verifyType(
  arg: any,
  targetClass: any,
  targetType: string,
  argIdx: number
) {
  if (arg instanceof targetClass) {
    return true
  }
  throw new FunctionCallTypeMismatchError({
    argIdx,
    expectedType: targetType,
    actualType: typeof arg,
  })
}
