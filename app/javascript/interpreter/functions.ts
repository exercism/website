import { Environment } from './environment'
import { Interpreter } from './interpreter'
import { FunctionStatement } from './statement'
import type { ExecutionContext } from './executor'

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
    private closure: Environment
  ) {}

  arity(): Arity {
    return [
      this.declaration.parameters.filter((p) => p.defaultValue === null).length,
      this.declaration.parameters.length,
    ]
  }

  call(interpreter: Interpreter, args: any[]): any {
    const environment = new Environment(this.closure)

    for (let i = 0; i < this.declaration.parameters.length; i++) {
      const arg =
        i < args.length
          ? args[i]
          : interpreter.evaluate(this.declaration.parameters[i].defaultValue!)
              .value
      environment.define(this.declaration.parameters[i].name.lexeme, arg)
    }

    try {
      interpreter.executeBlock(this.declaration.body, environment)
    } catch (error: unknown) {
      if (error instanceof ReturnValue) {
        return error.value
      }

      throw error
    }

    return null
  }
}
