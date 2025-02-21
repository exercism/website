import { RuntimeError, type RuntimeErrorType, type StaticError } from './error'
import { FunctionCallExpression, Expression } from './expression'
import { Location } from './location'
import { Parser } from './parser'
import { Executor } from './executor'
import { Statement } from './statement'
import type { TokenType } from './token'
import { translate } from './translator'
import type { ExternalFunction } from './executor'
import type { Frame } from './frames'
import { expr } from 'jquery'
import { formatJikiObject } from './helpers'
import * as Jiki from './jikiObjects'

export type FrameContext = {
  result: any
  expression?: Expression
  statement?: Statement
}

export interface SomethingWithLocation {
  location: Location
}

export type CompilationError = {
  type: 'CompilationError'
  error: StaticError
  frames: Frame[]
}

export type Toggle = 'ON' | 'OFF'

export type LanguageFeatures = {
  includeList?: TokenType[]
  excludeList?: TokenType[]
  repeatDelay: number
  maxTotalLoopIterations: number
  maxRepeatUntilGameOverIterations: number
  maxTotalExecutionTime: number
  allowGlobals: boolean
}

export type InputLanguageFeatures = {
  includeList?: TokenType[]
  excludeList?: TokenType[]
  repeatDelay?: number
  maxTotalLoopIterations?: number
  maxRepeatUntilGameOverIterations?: number
  maxTotalExecutionTime?: number
  allowGlobals?: boolean
}

export type EvaluationContext = {
  externalFunctions?: ExternalFunction[]
  classes?: Jiki.Class[]
  languageFeatures?: InputLanguageFeatures
  state?: Record<string, any>
  wrapTopLevelStatements?: boolean
}

export type EvaluateFunctionResult = InterpretResult & {
  value: any
}

export type InterpretResult = {
  frames: Frame[]
  error: StaticError | null
  meta: Meta
}

export type Meta = {
  functionCallLog: Record<string, Record<any, number>>
  statements: Statement[]
  sourceCode: string
}

export function compile(sourceCode: string, context: EvaluationContext = {}) {
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
  context: EvaluationContext = {}
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
  context: EvaluationContext = {},
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
  private classes: Jiki.Class[] = []
  private wrapTopLevelStatements = false

  private statements: Statement[] = []

  constructor(private readonly sourceCode: string, context: EvaluationContext) {
    // Set the instance variables based on the context that's been passed in.
    if (context.state !== undefined) {
      this.state = context.state
    }
    this.externalFunctions = context.externalFunctions
      ? context.externalFunctions
      : []

    this.classes = context.classes ? context.classes : []

    this.languageFeatures = {
      includeList: undefined,
      excludeList: undefined,
      repeatDelay: 0,
      maxRepeatUntilGameOverIterations: 100,
      maxTotalLoopIterations: 100,
      maxTotalExecutionTime: 10 * 1000, // 10 seconds
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
      throw { type: 'CompilationError', frames: [], error: error }
    }
  }

  public execute(): InterpretResult {
    const executor = new Executor(
      this.sourceCode,
      this.languageFeatures,
      this.externalFunctions,
      this.classes,
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
      this.externalFunctions,
      this.classes
    )
    const generalExec = executor.execute(this.statements)
    const exprExec = executor.evaluateSingleExpression(callingStatements[0])

    return {
      ...exprExec,
      meta: {
        ...exprExec.meta,
        statements: generalExec.meta.statements,
      },
    }
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
