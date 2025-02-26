import { isString } from './checks'
import { ExecutionContext } from './executor'
import { Arity } from './functions'

type ObjectType =
  | 'number'
  | 'string'
  | 'boolean'
  | 'list'
  | 'dictionary'
  | 'instance'

export abstract class JikiObject {
  public readonly objectId: string
  constructor(public readonly type: ObjectType) {
    this.objectId = Math.random().toString(36).substring(7)
  }

  public abstract toArg()
  public abstract toString(): string
}

export class Method {
  constructor(
    public readonly name: string,
    public readonly arity: Arity,
    public readonly fn: (
      executionContext: ExecutionContext,
      ...args
    ) => JikiObject | null
  ) {}
}

export type Getter = (
  executionContext: ExecutionContext
) => JikiObject | undefined
export type Setter = (
  executionContext: ExecutionContext,
  value: JikiObject
) => void

export class Class {
  private initialize: ((...args: any[]) => void) | undefined
  constructor(public readonly name: string) {}
  private readonly methods: Record<string, Method> = {}
  private readonly getters: Record<string, Getter> = {}
  private readonly setters: Record<string, Setter> = {}
  public arity: Arity = 0

  public instantiate(
    executionContext: ExecutionContext,
    args: JikiObject[]
  ): Instance {
    const instance = new Instance(this)

    if (this.initialize !== undefined) {
      this.initialize.apply(instance, [executionContext, ...args])
    }

    return instance
  }
  public addConstructor(
    fn: (executionContext: ExecutionContext, ...args: any[]) => void
  ) {
    this.initialize = fn
    this.arity = fn.length - 1
  }

  //
  // Methods
  //
  public addMethod(
    name: string,
    fn: (
      executionContext: ExecutionContext,
      ...args: any[]
    ) => JikiObject | null
  ) {
    // Reduce the arity by 1 because the first argument is the execution context
    // which is invisible to the user
    const arity = fn.length - 1
    this.methods[name] = new Method(name, arity, fn)
  }
  public getMethod(name: string): Method | undefined {
    return this.methods[name]
  }

  //
  // Getters and Setters
  //
  public getGetter(name: string): Getter | undefined {
    return this.getters[name]
  }
  public getSetter(name: string): Setter | undefined {
    return this.setters[name]
  }
  public addGetter(
    name: string,
    fn?: (
      this: Instance,
      executionContext: ExecutionContext
    ) => JikiObject | undefined
  ) {
    if (fn === undefined) {
      fn = function (this: Instance, _: ExecutionContext) {
        return this.fields[name]
      }
    }
    this.getters[name] = fn
  }
  public addSetter(
    name: string,
    fn?: (
      this: Instance,
      executionContext: ExecutionContext,
      value: JikiObject
    ) => void
  ) {
    if (fn === undefined) {
      fn = function (this: Instance, x: ExecutionContext, value: JikiObject) {
        this.fields[name] = value
      }
    }
    this.setters[name] = fn
  }
}

export class Instance extends JikiObject {
  protected fields: Record<string, JikiObject> = {}

  constructor(private jikiClass: Class) {
    super('instance')
  }
  public toArg(): Instance {
    return this
  }
  public toString() {
    return `(an instance of ${this.jikiClass.name})`
  }
  public getMethod(name: string): Method | undefined {
    return this.jikiClass.getMethod(name)
  }
  public getGetter(name: string): Getter | undefined {
    return this.jikiClass.getGetter(name)
  }
  public getSetter(name: string): Setter | undefined {
    return this.jikiClass.getSetter(name)
  }
  public getField(name: string): JikiObject | undefined {
    return this.fields[name]
  }
  public getUnwrappedField(name: string): any {
    return unwrapJikiObject(this.fields[name])
  }
  public setField(name: string, value: JikiObject): void {
    this.fields[name] = value
  }
}

export abstract class Primitive extends JikiObject {
  constructor(public readonly type: ObjectType, public readonly value: any) {
    super(type)
  }

  public toString() {
    return JSON.stringify(this.value)
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
  public toArg(): Number {
    return new Number(this.value)
  }
}

export class String extends Literal {
  constructor(value: string) {
    super('string', value)
  }
  public toArg(): String {
    return new String(this.value)
  }
}

export class Boolean extends Literal {
  constructor(value: boolean) {
    super('boolean', value)
  }
  public toArg(): Boolean {
    return new Boolean(this.value)
  }
}
export const True = new Boolean(true)
export const False = new Boolean(false)

export class List extends Primitive {
  constructor(value: JikiObject[]) {
    super('list', value)
  }
  public toArg(): List {
    return new List(this.value.map((item) => item.toArg()))
  }
  public toString() {
    if (this.value.length === 0) {
      return '[]'
    }
    return `[ ${this.value.map((item) => item.toString()).join(', ')} ]`
  }
}

export class Dictionary extends Primitive {
  constructor(value: Map<string, JikiObject>) {
    super('dictionary', value)
  }
  public toArg(): Dictionary {
    return new Dictionary(
      new Map(
        [...this.value.entries()].map(([key, value]) => [key, value.toArg()])
      )
    )
  }
  public toString() {
    if (this.value.size === 0) {
      return '{}'
    }
    const stringified = Object.fromEntries(
      [...this.value.entries()].map(([key, value]) => [
        key,
        unwrapJikiObject(value),
      ])
    )

    return JSON.stringify(stringified, null, 1).replace(/\n\s*/g, ' ')
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
  if (value instanceof Instance) {
    return 'Instance'
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
