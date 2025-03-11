import { RuntimeError, type RuntimeErrorType, type StaticError } from './error'
import { Expression } from './expression'
import { Location } from './location'
import { Parser } from './parser'
import { Executor } from './executor'
import { Statement } from './statement'
import type { TokenType } from './token'
import { translate } from './translator'
import type { ExecutionContext, ExternalFunction } from './executor'
import type { Frame } from './frames'

export type FrameContext = {
  result: any
  expression?: Expression
  statement?: Statement
}

export type CompilationError = {
  type: 'CompilationError'
  error: StaticError
  frames: Frame[]
}

export type Toggle = 'ON' | 'OFF'

export type InterpretResult = {
  frames: Frame[]
  error: StaticError | null
}

export function compile(sourceCode: string) {
  const interpreter = new Interpreter(sourceCode)
  try {
    interpreter.compile()
  } catch (data: any) {
    return data
  }
  return {}
}
export function interpret(sourceCode: string): InterpretResult {
  const interpreter = new Interpreter(sourceCode)
  try {
    interpreter.compile()
  } catch (data: any) {
    return data
  }
  return interpreter.execute()
}

export class Interpreter {
  private readonly parser: Parser

  private state: Record<string, any> = {}
  private externalFunctions: ExternalFunction[] = []
  private statements: Statement[] = []

  constructor(private readonly sourceCode: string) {
    this.parser = new Parser()
  }

  public compile() {
    try {
      this.statements = this.parser.parse(this.sourceCode)
    } catch (error: unknown) {
      throw { type: 'CompilationError', frames: [], error: error }
    }
  }

  public execute(): InterpretResult {
    const executor = new Executor(this.sourceCode)
    return executor.execute(this.statements)
  }

  private error(
    type: RuntimeErrorType,
    location: Location | null,
    context: any = {}
  ): never {
    // Unwrap context values from jiki objects
    context = Jiki.unwrapJikiObject(context)
    throw new RuntimeError(
      translate(`error.runtime.${type}`, context),
      location,
      type,
      context
    )
  }
}
