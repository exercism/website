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
import { Arity } from './functions'
import * as Jiki from './jikiObjects'
import { StdlibFunctions, StdlibFunctionsForLibrary } from './stdlib'

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

export class CustomFunctionError extends Error {
  constructor(message: string) {
    super(message)
  }
}

export type Toggle = 'ON' | 'OFF'

export type LanguageFeatures = {
  includeList?: TokenType[]
  excludeList?: TokenType[]
  timePerFrame: number
  repeatDelay: number
  maxTotalLoopIterations: number
  maxRepeatUntilGameOverIterations: number
  maxTotalExecutionTime: number
  allowGlobals: boolean
  customFunctionDefinitionMode: boolean
  addSuccessFrames: boolean
}

export type InputLanguageFeatures = {
  includeList?: TokenType[]
  excludeList?: TokenType[]
  timePerFrame?: number
  repeatDelay?: number
  maxTotalLoopIterations?: number
  maxRepeatUntilGameOverIterations?: number
  maxTotalExecutionTime?: number
  allowGlobals?: boolean
  customFunctionDefinitionMode?: boolean
  addSuccessFrames?: boolean
}

export type CustomFunction = {
  name: string
  arity: Arity
  code: string
}
export type CallableCustomFunction = {
  name: string
  arity: Arity
  call: () => any
}

export type EvaluationContext = {
  externalFunctions?: ExternalFunction[]
  customFunctions?: CustomFunction[]
  classes?: Jiki.Class[]
  languageFeatures?: InputLanguageFeatures
  state?: Record<string, any>
  wrapTopLevelStatements?: boolean
}

export type EvaluateFunctionResult = InterpretResult & {
  value: any
  jikiObject?: Jiki.JikiObject
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
export function evaluateExpression(
  sourceCode: string,
  context: EvaluationContext = {},
  expression: string,
  ...args: any[]
): EvaluateFunctionResult {
  const interpreter = new Interpreter(sourceCode, context)
  interpreter.compile()
  return interpreter.evaluateExpression(expression, ...args)
}

export class Interpreter {
  private readonly parser: Parser

  private state: Record<string, any> = {}
  private languageFeatures: LanguageFeatures
  private externalFunctions: ExternalFunction[] = []
  private customFunctions: CallableCustomFunction[] = []
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

    this.customFunctions = this.parseCustomFunctions(
      context.customFunctions ? context.customFunctions : []
    )
    this.classes = context.classes ? context.classes : []

    this.languageFeatures = {
      includeList: undefined,
      excludeList: undefined,
      timePerFrame: 0.01,
      repeatDelay: 0,
      maxRepeatUntilGameOverIterations: 100,
      maxTotalLoopIterations: 10000,
      maxTotalExecutionTime: 10000, // 10 seconds
      allowGlobals: false,
      customFunctionDefinitionMode: false,
      addSuccessFrames: true,
      ...context.languageFeatures,
    }

    this.parser = new Parser(
      this.externalFunctions.map((f) => f.name),
      this.languageFeatures,
      this.wrapTopLevelStatements
    )
  }

  private parseCustomFunctions(
    customFunctions: CustomFunction[]
  ): CallableCustomFunction[] {
    // This is wildly deeply recursive so be careful!
    if (customFunctions.length === 0) return []

    customFunctions = customFunctions.reduce((acc, fn) => {
      if (!acc.some((existingFn) => existingFn.name === fn.name)) {
        acc.push(fn)
      }
      return acc
    }, [] as CustomFunction[])

    const code = customFunctions.map((fn) => fn.code).join('\n')
    const interpreter = new Interpreter(code, {
      languageFeatures: {
        customFunctionDefinitionMode: true,
        maxTotalLoopIterations: 100000,
        addSuccessFrames: false,
      },
      externalFunctions: StdlibFunctionsForLibrary,
    })
    interpreter.compile()

    return customFunctions.map((customFunction) => {
      const call = (_: ExecutionContext, args) => {
        const nakedArgs = args.map((arg) => {
          // TODO: Need to check for lists etc too
          if (arg instanceof Jiki.Instance) {
            this.error(
              'UnexpectedObjectArgumentForCustomFunction',
              Location.unknown
            )
          }
          return Jiki.unwrapJikiObject(arg)
        })
        const res = interpreter.evaluateFunction(
          customFunction.name,
          ...nakedArgs
        )
        if (res.error) {
          throw new CustomFunctionError(res.error.message)
        } else if (res.frames.at(-1)?.error) {
          throw new CustomFunctionError(res.frames.at(-1)!.error!.message)
        }

        return res.jikiObject
      }
      return { ...customFunction, call }
    })
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
      this.customFunctions,
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
      this.customFunctions,
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

  public evaluateExpression(
    expression: string,
    ...args: any[]
  ): EvaluateFunctionResult {
    // Create a new parser with wrapTopLevelStatements set to false
    // and use it to generate the calling statements.
    const callingStatements = new Parser(
      this.externalFunctions.map((f) => f.name),
      this.languageFeatures,
      false
    ).parse(expression)

    if (callingStatements.length !== 1)
      this.error('CouldNotEvaluateFunction', Location.unknown, {
        callingStatements,
      })

    const executor = new Executor(
      this.sourceCode,
      this.languageFeatures,
      this.externalFunctions,
      this.customFunctions,
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
