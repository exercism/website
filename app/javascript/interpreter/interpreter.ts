import { RuntimeError, type RuntimeErrorType, type StaticError } from './error'
import { Expression } from './expression'
import { Location } from './location'
import { Parser } from './parser'
import { Executor } from './executor'
import { Statement } from './statement'
import type { TokenType } from './token'
import { translate } from './translator'
import type { ExternalFunction } from './executor'
import type { Frame } from './frames'

export type FrameContext = {
  result: any
  expression?: Expression
  statement?: Statement
}

export type Toggle = 'ON' | 'OFF'

export type LanguageFeatures = {
  includeList?: TokenType[]
  excludeList?: TokenType[]
  repeatDelay: number
  allowGlobals: boolean
}

export type InputLanguageFeatures = {
  includeList?: TokenType[]
  excludeList?: TokenType[]
  repeatDelay?: number
  allowGlobals?: boolean
}

export type Context = {
  externalFunctions?: ExternalFunction[]
  languageFeatures?: InputLanguageFeatures
  state?: Record<string, any>
  wrapTopLevelStatements?: boolean
}

export type EvaluateFunctionResult = {
  value: any
  frames: Frame[]
  error: StaticError | null
}

export type InterpretResult = {
  frames: Frame[]
  error: StaticError | null
}

export function compile(sourceCode: string, context: Context = {}) {
  const interpreter = new Interpreter(sourceCode, context)
  try {
    interpreter.compile()
  } catch (data: any) {
    return data
  }
  return {}
}
export function interpret(
  sourceCode: string,
  context: Context = {}
): InterpretResult {
  const interpreter = new Interpreter(sourceCode, context)
  try {
    interpreter.compile()
  } catch (data: any) {
    return data
  }
  return interpreter.execute()
}

export function evaluateFunction(
  sourceCode: string,
  context: Context = {},
  functionCall: string,
  ...args: any[]
): EvaluateFunctionResult {
  const interpreter = new Interpreter(sourceCode, context)
  interpreter.compile()
  return interpreter.evaluateFunction(functionCall, ...args)
}

export class Interpreter {
  private readonly parser: Parser

  private state: Record<string, any> = {}
  private languageFeatures: LanguageFeatures
  private externalFunctions: ExternalFunction[] = []
  private wrapTopLevelStatements = false

  private statements: Statement[] = []

  constructor(private readonly sourceCode: string, context: Context) {
    // Set the instance variables based on the context that's been passed in.
    if (context.state !== undefined) {
      this.state = context.state
    }
    this.externalFunctions = context.externalFunctions
      ? context.externalFunctions
      : []

    this.languageFeatures = {
      includeList: undefined,
      excludeList: undefined,
      repeatDelay: 0,
      allowGlobals: false,
      ...context.languageFeatures,
    }

    this.parser = new Parser(
      this.externalFunctions.map((f) => f.name),
      this.languageFeatures,
      this.wrapTopLevelStatements
    )
  }

  public compile() {
    try {
      this.statements = this.parser.parse(this.sourceCode)
    } catch (error: unknown) {
      throw { frames: [], error: error }
    }
  }

  public execute(): InterpretResult {
    const executor = new Executor(
      this.sourceCode,
      this.languageFeatures,
      this.externalFunctions,
      this.state
    )
    return executor.execute(this.statements)
  }

  public evaluateFunction(
    name: string,
    ...args: any[]
  ): EvaluateFunctionResult {
    const callingCode = `${name}(${args
      .map((arg) => JSON.stringify(arg))
      .join(', ')})`

    // Create a new parser with wrapTopLevelStatements set to false
    // and use it to generate the calling statements.
    const callingStatements = new Parser(
      this.externalFunctions.map((f) => f.name),
      this.languageFeatures,
      false
    ).parse(callingCode)

    if (callingStatements.length !== 1)
      this.error('CouldNotEvaluateFunction', Location.unknown, {
        callingStatements,
      })

    const executor = new Executor(
      this.sourceCode,
      this.languageFeatures,
      this.externalFunctions
    )
    executor.execute(this.statements)
    return executor.evaluateSingleExpression(callingStatements[0])
  }

  private error(
    type: RuntimeErrorType,
    location: Location | null,
    context: any = {}
  ): never {
    throw new RuntimeError(
      translate(`error.runtime.${type}`, context),
      location,
      type,
      context
    )
  }
}
