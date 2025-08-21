import { Environment } from './environment'
import {
  ConstructorStatement,
  FunctionStatement,
  MethodStatement,
} from './statement'
import type { ExecutionContext } from './executor'
import { Location } from './location'
import * as Jiki from './jikiObjects'

export type Arity = number | [min: number, max: number]

export interface Callable {
  arity: Arity
  call(context: ExecutionContext, args: any[]): Jiki.JikiObject | void
}

export class ReturnValue extends Error {
  constructor(public value: any, public location: Location) {
    super()
  }
}

export function isCallable(obj: any): obj is Callable {
  return obj instanceof Object && 'arity' in obj && 'call' in obj
}

class UserDefinedCallable implements Callable {
  public readonly arity: Arity

  constructor(
    private declaration:
      | FunctionStatement
      | ConstructorStatement
      | MethodStatement
  ) {
    this.arity = [
      this.declaration.parameters.filter((p) => p.defaultValue === null).length,
      this.declaration.parameters.length,
    ]
  }

  public call(executor: ExecutionContext, args: Jiki.JikiObject[]): any {
    const environment = new Environment()

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

export class UserDefinedMethod extends UserDefinedCallable {
  constructor(declaration: ConstructorStatement | MethodStatement) {
    super(declaration)
  }
}

export class UserDefinedFunction extends UserDefinedCallable {
  constructor(declaration: FunctionStatement) {
    super(declaration)
  }
}
