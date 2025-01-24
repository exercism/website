import { type Callable, isCallable } from './functions'
import { RuntimeError } from './error'
import type { Token } from './token'
import didYouMean from 'didyoumean'
import { translate } from './translator'
import { isString } from './checks'

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

  public define(name: string, value: any): void {
    this.values.set(name, value)
  }

  public get(name: Token): any {
    if (this.values.has(name.lexeme)) return this.values.get(name.lexeme)

    // Try the enclosing environment(s), but handle the error here so we can
    // make use of the didYouMean function
    try {
      if (this.enclosing !== null) return this.enclosing.get(name)
    } catch (e) {}

    const variableNames = Object.keys(this.variables())
    const functionNames = Object.keys(this.functions())

    return undefined
    throw new RuntimeError(
      translate('error.runtime.CouldNotFindValueWithName', {
        name: name.lexeme,
      }),
      name.location,
      'CouldNotFindValueWithName',
      {
        didYouMean: {
          variable: didYouMean(name.lexeme, variableNames),
          function: didYouMean(name.lexeme, functionNames),
        },
      }
    )
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

    throw new RuntimeError(
      translate('error.runtime.couldNotFindValueWithName', {
        name: name.lexeme,
      }),
      name.location,
      'CouldNotFindValueWithName'
    )
  }

  public variables(): Record<string, any> {
    let current: Environment | null = this
    let vars: any = {}

    while (current != null) {
      for (const [key, value] of this.values) {
        if (key in vars) continue
        if (isCallable(value)) continue

        // The stringify/parse combination makes the value unique,
        // which means that subsequent updates won't influence the
        // value of previous frames
        let normalizedValue
        try {
          normalizedValue = JSON.parse(JSON.stringify(value))
        } catch (e) {
          normalizedValue = undefined
        }
        vars[key] = normalizedValue
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
        if (!isCallable(value)) continue

        functions[key] = value
      }

      current = current.enclosing
    }

    return functions
  }
}
