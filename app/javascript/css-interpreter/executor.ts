import { RuntimeError, type RuntimeErrorType, isRuntimeError } from './error'

import { Location } from './location'

import {
  Statement,
  SelectorStatement,
  PropertyStatement,
  Selector,
} from './statement'

import { translate } from './translator'
import type { InterpretResult } from './interpreter'

import type { Frame, FrameExecutionStatus, Animation } from './frames'
import { describeFrame } from './frames'

export class Executor {
  private frames: Frame[] = []
  private location: Location | null = null
  private time: number = 0
  private timePerFrame = 10
  private selectors: Selector[][] = []

  constructor(private readonly sourceCode: string) {}

  public execute(statements: Statement[]): InterpretResult {
    for (const statement of statements) {
      try {
        this.executeStatement(statement)
      } catch (error) {
        if (isRuntimeError(error)) {
          this.addFrame(
            this.location || error.location,
            'ERROR',
            undefined,
            error
          )
          break
        }

        throw error
      }
    }

    return {
      frames: this.frames,
      error: null,
    }
  }
  public executeStatement(statement: Statement): void {
    const method = `visit${statement.type}`
    this[method](statement)
  }

  public visitSelectorStatement(statement: SelectorStatement): void {
    this.selectors.push(statement.selectors)
    try {
      for (const stmt of statement.body) {
        this.executeStatement(stmt)
      }
    } finally {
      this.selectors.pop()
    }
  }

  public visitPropertyStatement(statement: PropertyStatement) {
    const animations = this.currentSelectors().map((currentSelector) => {
      return {
        selector: currentSelector,
        property: statement.property.lexeme,
        value: statement.value.value,
      }
    })
    this.addSuccessFrame(statement.location, animations, statement)
  }

  private currentSelectors(): string[] {
    let strings: string[] = []
    // For each level of selectors, take the existing strings
    // and make a copy for each selector.
    this.selectors.forEach(
      (selectors) =>
        (strings = selectors
          .map((selector) => {
            if (strings.length == 0) return selector.literal
            return strings.map((string) => `${string} ${selector.literal}`)
          })
          .flat())
    )
    return strings
  }

  public addSuccessFrame(
    location: Location | null,
    animations: Animation[],
    context?: PropertyStatement
  ): void {
    this.addFrame(location, 'SUCCESS', animations, undefined, context)
  }

  public addErrorFrme(
    location: Location | null,
    error: RuntimeError,
    context?: PropertyStatement
  ): void {
    this.addFrame(location, 'ERROR', [], error, context)
  }

  private addFrame(
    location: Location | null,
    status: FrameExecutionStatus,
    animations: Animation[],
    error?: RuntimeError,
    context?: PropertyStatement
  ): void {
    if (location == null) location = Location.unknown

    const frame: Frame = {
      code: location.toCode(this.sourceCode),
      line: location.line,
      status,
      animations,
      error,
      time: this.time,
      // Multiple the time by 100 and floor it to get an integer
      timelineTime: Math.round(this.time * 100),
      description: '',
      context: context,
    }
    frame.description = describeFrame(frame)
    this.frames.push(frame)

    this.time += this.timePerFrame
  }

  public error(
    type: RuntimeErrorType,
    location: Location | null,
    context: any = {}
  ): never {
    throw this.buildError(type, location, context)
  }

  private buildError(
    type: RuntimeErrorType,
    location: Location | null,
    context: any = {}
  ): RuntimeError {
    // Unwrap context values from jiki objects
    context = Jiki.unwrapJikiObject(context)

    let message
    if (type == 'LogicError') {
      message = context.message
    } else {
      message = translate(`error.runtime.${type}`, context)
    }

    return new RuntimeError(message, location, type, context)
  }
}
