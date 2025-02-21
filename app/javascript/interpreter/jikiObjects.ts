import { PrimaryButton } from '@/components/mentoring/representation/common/PrimaryButton'
import { isString } from './checks'
import { ExecutionContext } from './executor'
import { Arity } from './functions'

type ObjectType = 'number' | 'string' | 'boolean' | 'list' | 'dictionary'

// This seems to be required sadly.
// If you change it, check an example method in call-methods.test.ts
// to see if that then complains.
type MethodArgs1 = [ExecutionContext, JikiObject]
type MethodArgs2 = [ExecutionContext, JikiObject, JikiObject]
type MethodArgs3 = [ExecutionContext, JikiObject, JikiObject, JikiObject]
type MethodArgs4 = [
  ExecutionContext,
  JikiObject,
  JikiObject,
  JikiObject,
  JikiObject
]
type MethodArgs5 = [
  ExecutionContext,
  JikiObject,
  JikiObject,
  JikiObject,
  JikiObject,
  JikiObject
]
type MethodArgs =
  | MethodArgs1
  | MethodArgs2
  | MethodArgs3
  | MethodArgs4
  | MethodArgs5

export class Method {
  constructor(
    public readonly name: string,
    public readonly arity: Arity,
    public readonly fn: (...MethodArgs) => JikiObject | null
  ) {}
}

export abstract class JikiObject {
  public readonly id: string
  constructor(public readonly type: ObjectType, public readonly value: any) {
    this.id = Math.random().toString(36).substring(7)
  }
  public toArg(): this {
    return this
  }

  public abstract clone(): JikiObject
  public methods: Map<string, Method> = new Map()
}
export abstract class Primitive extends JikiObject {
  constructor(public readonly type: ObjectType, public readonly value: any) {
    super(type, value)
  }
  public toArg<T extends this>(): T {
    return this.clone() as T
  }
}

export abstract class Literal extends Primitive {
  constructor(public readonly type: ObjectType, public readonly value: any) {
    super(type, value)
  }
}

export class Number extends Literal {
  constructor(value: number) {
    super('number', value)
  }
  public clone(): JikiObject {
    return new Number(this.value)
  }
}

export class String extends Literal {
  constructor(value: string) {
    super('string', value)
  }
  public clone(): JikiObject {
    return new String(this.value)
  }
}

export class Boolean extends Literal {
  constructor(value: boolean) {
    super('boolean', value)
  }
  public clone(): JikiObject {
    return new Boolean(this.value)
  }
}

export class List extends Primitive {
  constructor(value: JikiObject[]) {
    super('list', value)
  }
  public clone(): JikiObject {
    return new List(this.value.map((item) => item.clone()))
  }
}

export class Dictionary extends Primitive {
  constructor(value: Map<string, JikiObject>) {
    super('dictionary', value)
  }
  public clone(): JikiObject {
    const y = new Map(
      [...this.value.entries()].map(([key, value]) => [key, value.clone()])
    )

    return new Dictionary(y)
  }
}

export function unwrapJikiObject(value: any): any {
  if (value === null) {
    return null
  }
  if (value === undefined) {
    return undefined
  }

  if (value instanceof Literal) {
    return value.value
  }
  if (value instanceof List) {
    return value.value.map(unwrapJikiObject)
  }
  if (value instanceof Dictionary) {
    return Object.fromEntries(
      [...value.value.entries()].map(([key, value]) => [
        key,
        unwrapJikiObject(value),
      ])
    )
  }
  if (value instanceof Array) {
    return value.map(unwrapJikiObject)
  }
  if (
    typeof value === 'number' ||
    typeof value === 'string' ||
    typeof value === 'boolean'
  ) {
    return value
  }
  if (typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value).map(([key, value]) => [
        key,
        unwrapJikiObject(value),
      ])
    )
  }

  return value
}

export function wrapJSToJikiObject(value: any) {
  if (value === null) {
    return null
  }
  if (value === undefined) {
    return undefined
  }

  if (value instanceof JikiObject) {
    return value
  }
  if (isString(value)) {
    return new String(value)
  }
  if (typeof value === 'number') {
    return new Number(value)
  }
  if (typeof value === 'boolean') {
    return new Boolean(value)
  }
  if (Array.isArray(value)) {
    return new List(value.map(wrapJSToJikiObject))
  }
  return new Dictionary(
    new Map(
      [...value.entries()].map(([key, value]) => [
        key,
        wrapJSToJikiObject(value),
      ])
    )
  )
}
