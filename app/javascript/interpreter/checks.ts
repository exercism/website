export function isNumber(obj: any): obj is number {
  return typeof obj === 'number' || obj instanceof Number
}

export function isBoolean(obj: any): obj is boolean {
  return typeof obj === 'boolean' || obj instanceof Boolean
}

export function isString(obj: any): obj is string {
  return typeof obj === 'string' || obj instanceof String
}

export function isArray(obj: any): obj is Array<unknown> {
  return obj instanceof Array
}

export function isObject(obj: any): obj is Object {
  return obj instanceof Object
}
