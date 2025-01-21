import { Environment } from './environment'
import { Interpreter, LanguageFeatures } from './interpreter'
import { FunctionStatement } from './statement'
import type { ExecutionContext, Executor } from './executor'

export type Arity = number | [min: number, max: number]

export interface Callable {
  arity(): Arity
  call(context: ExecutionContext, args: any[]): any
}

export class ReturnValue extends Error {
  constructor(public value: any) {
    super()
  }
}

export function isCallable(obj: any): obj is Callable {
  return obj instanceof Object && 'arity' in obj && 'call' in obj
}

export class UserDefinedFunction implements Callable {
  constructor(
    private declaration: FunctionStatement,
    private closure: Environment,
    private languageFeatures: LanguageFeatures
  ) {}

  arity(): Arity {
    return [
      this.declaration.parameters.filter((p) => p.defaultValue === null).length,
      this.declaration.parameters.length,
    ]
  }

  call(executor: ExecutionContext, args: any[]): any {
    let environment
    if (this.languageFeatures.allowGlobals) {
      environment = new Environment(this.closure)
    } else {
      environment = new Environment()
    }

    for (let i = 0; i < this.declaration.parameters.length; i++) {
      const arg =
        i < args.length
          ? args[i]
          : executor.evaluate(this.declaration.parameters[i].defaultValue!)
              .value
      environment.define(this.declaration.parameters[i].name.lexeme, arg)
    }

    try {
      executor.executeBlock(this.declaration.body, environment)
    } catch (error: unknown) {
      if (error instanceof ReturnValue) {
        return error.value
      }

      throw error
    }

    return null
  }
}
