import { type Callable, isCallable, UserDefinedFunction } from './functions'
import type { Token } from './token'
import { isString } from './checks'
import * as Jiki from './jikiObjects'

export class Environment {
  private readonly values: Map<string, any> = new Map()
  public readonly id // Useful for debugging

  constructor(private readonly enclosing: Environment | null = null) {
    this.id = Math.random().toString(36).substring(7)
  }

  public inScope(name: Token | string): boolean {
    const nameString = isString(name) ? name : name.lexeme

    if (this.values.has(nameString)) {
      return true
    }
    if (this.enclosing !== null) {
      return this.enclosing.inScope(nameString)
    }
    return false
  }

  public define(
    name: string,
    value: Jiki.JikiObject | Jiki.Class | UserDefinedFunction
  ): void {
    this.values.set(name, value)
  }

  public undefine(name: string): void {
    this.values.delete(name)
  }

  public get(name: Token): any {
    if (this.values.has(name.lexeme)) return this.values.get(name.lexeme)

    // Try the enclosing environment(s), but handle the error here so we can
    // make use of the didYouMean function
    try {
      if (this.enclosing !== null) return this.enclosing.get(name)
    } catch (e) {}
  }

  public updateVariable(name: Token, value: any): void {
    if (this.values.has(name.lexeme)) {
      this.values.set(name.lexeme, value)
      return
    }

    if (this.enclosing?.get(name)) {
      this.enclosing?.updateVariable(name, value)
      return
    }
  }

  public variables(): Record<string, any> {
    let current: Environment | null = this
    let vars: any = {}

    while (current != null) {
      for (const [key, value] of this.values) {
        if (key in vars) continue
        if (value instanceof Jiki.Class) continue
        if (isCallable(value)) continue

        vars[key] = value
      }

      current = current.enclosing
    }

    return vars
  }

  public functions(): Record<string, Callable> {
    let current: Environment | null = this
    let functions: any = {}

    while (current != null) {
      for (const [key, value] of this.values) {
        if (key in functions) continue
        if (value instanceof Jiki.Class) continue
        if (!isCallable(value)) continue

        functions[key] = value
      }

      current = current.enclosing
    }

    return functions
  }
}
