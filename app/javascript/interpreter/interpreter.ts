import {
  RuntimeError,
  type RuntimeErrorType,
  type StaticError,
  isStaticError,
} from './error'
import { Expression } from './expression'
import { Location } from './location'
import { Parser as JavaScriptParser } from './languages/javascript/parser'
import { Parser as JikiScriptParser } from './languages/jikiscript/parser'
import { Executor } from './executor'
import { Statement } from './statement'
import type { TokenType } from './token'
import { Resolver } from './resolver'
import { translate } from './translator'
import type { ExternalFunction } from './executor'
import type { Frame } from './frames'

export type Language = 'JikiScript' | 'JavaScript'
const LanguageSettings = {
  JikiScript: {
    allowVariableReassigmment: true,
  },
  JavaScript: {
    allowVariableReassigmment: false,
  },
}

interface ParserConstructor {
  new (
    functionNames: string[],
    languageFeatures: any,
    wrapTopLevelStatements: boolean
  ): Parser
}

export interface Parser {
  parse(sourceCode: string): Statement[]
}

export type FrameContext = {
  result: any
  expression?: Expression
  statement?: Statement
}

export type Toggle = 'ON' | 'OFF'

export type LanguageFeatures = {
  IncludeList?: TokenType[]
  ExcludeList?: TokenType[]
  shadowing?: Toggle
  truthiness?: Toggle
  repeatDelay?: number
}

export type Context = {
  externalFunctions?: ExternalFunction[]
  language?: Language
  languageFeatures?: LanguageFeatures
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

export function interpretJavaScript(sourceCode: string, context: Context = {}) {
  return interpret(sourceCode, { ...context, language: 'JavaScript' })
}
export function interpretJikiScript(sourceCode: string, context: Context = {}) {
  return interpret(sourceCode, { ...context, language: 'JikiScript' })
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

export function evaluateJavaScriptFunction(
  sourceCode: string,
  context: Context = {},
  functionCall: string,
  ...args: any[]
): EvaluateFunctionResult {
  return evaluateFunction(
    sourceCode,
    { ...context, language: 'JavaScript' },
    functionCall,
    ...args
  )
}
export function evaluateJikiScriptFunction(
  sourceCode: string,
  context: Context = {},
  functionCall: string,
  ...args: any[]
): EvaluateFunctionResult {
  return evaluateFunction(
    sourceCode,
    { ...context, language: 'JikiScript' },
    functionCall,
    ...args
  )
}
export function evaluateFunction(
  sourceCode: string,
  context: Context = {},
  functionCall: string,
  ...args: any[]
): EvaluateFunctionResult {
  const interpreter = new Interpreter(sourceCode, context)
  interpreter.compile()
  const res = interpreter.evaluateFunction(functionCall, ...args)
  // console.log(res)
  return res
}

export class Interpreter {
  private readonly parser: Parser
  private readonly resolver: Resolver

  private state: Record<string, any> = {}
  private language: Language
  private parserType: ParserConstructor
  private languageFeatures: LanguageFeatures = {}
  private externalFunctions: ExternalFunction[] = []
  private wrapTopLevelStatements = false

  private statements: Statement[] = []

  constructor(private readonly sourceCode: string, context: Context) {
    // Set the instance variables based on the context that's been passed in.
    this.language = context.language ? context.language : 'JavaScript'
    this.parserType =
      this.language == 'JavaScript' ? JavaScriptParser : JikiScriptParser

    if (context.state !== undefined) {
      this.state = context.state
    }
    this.externalFunctions = context.externalFunctions
      ? context.externalFunctions
      : []
    if (context.languageFeatures !== undefined) {
      this.languageFeatures = context.languageFeatures
    }

    this.parser = new this.parserType(
      this.externalFunctions.map((f) => f.name),
      this.languageFeatures,
      this.wrapTopLevelStatements
    )
    this.resolver = new Resolver(
      LanguageSettings[this.language].allowVariableReassigmment,
      this.externalFunctions.map((f) => f.name)
    )
  }

  public compile() {
    try {
      this.statements = this.parser.parse(this.sourceCode)
      this.resolver.resolve(this.statements)
    } catch (error: unknown) {
      throw { frames: [], error: error }
    }
  }

  public execute(): InterpretResult {
    const executor = new Executor(
      this.sourceCode,
      this.languageFeatures,
      this.externalFunctions,
      this.resolver.locals,
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
    const callingStatements = new this.parserType(
      this.externalFunctions.map((f) => f.name),
      this.languageFeatures,
      false
    ).parse(callingCode)

    if (callingStatements.length !== 1)
      this.error('CouldNotEvaluateFunction', Location.unknown, {
        callingStatements,
      })

    try {
      this.resolver.resolve(callingStatements)
    } catch (error: unknown) {
      if (isStaticError(error)) {
        return { value: undefined, frames: [], error: error }
      }
    }

    const executor = new Executor(
      this.sourceCode,
      this.languageFeatures,
      this.externalFunctions,
      this.resolver.locals
    )
    executor.execute(this.statements)
    return executor.evaluateSingleExpression(callingStatements[0])
  }

  // public resolve(expression: Expression, depth: number): void {
  //   this.resolver.locals.set(expression, depth);
  // }

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
