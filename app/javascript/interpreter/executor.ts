import {
  Arity,
  ReturnValue,
  UserDefinedFunction,
  isCallable,
} from './functions'
import { Environment } from './environment'
import {
  RuntimeError,
  type RuntimeErrorType,
  isRuntimeError,
  LogicError,
} from './error'
import {
  ListExpression,
  BinaryExpression,
  CallExpression,
  Expression,
  FunctionLookupExpression,
  GetElementExpression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  SetElementExpression,
  UnaryExpression,
  VariableLookupExpression,
  DictionaryExpression,
} from './expression'
import { Location, Span } from './location'
import {
  BlockStatement,
  FunctionStatement,
  IfStatement,
  RepeatStatement,
  RepeatUntilGameOverStatement,
  ReturnStatement,
  Statement,
  SetVariableStatement,
  ChangeVariableStatement,
  RepeatForeverStatement,
  CallStatement,
  LogStatement,
  ChangeElementStatement,
  ForeachStatement,
  BreakStatement,
  ContinueStatement,
} from './statement'
import type { Token } from './token'
import type {
  EvaluationResult,
  EvaluationResultBinaryExpression,
  EvaluationResultBreakStatement,
  EvaluationResultCallExpression,
  EvaluationResultChangeElementStatement,
  EvaluationResultChangeVariableStatement,
  EvaluationResultContinueStatement,
  EvaluationResultDictionaryExpression,
  EvaluationResultExpression,
  EvaluationResultForeachStatement,
  EvaluationResultFunctionLookupExpression,
  EvaluationResultGetElementExpression,
  EvaluationResultGroupingExpression,
  EvaluationResultIfStatement,
  EvaluationResultListExpression,
  EvaluationResultLiteralExpression,
  EvaluationResultLogicalExpression,
  EvaluationResultLogStatement,
  EvaluationResultRepeatStatement,
  EvaluationResultReturnStatement,
  EvaluationResultSetElementExpression,
  EvaluationResultSetVariableStatement,
  EvaluationResultUnaryExpression,
  EvaluationResultVariableLookupExpression,
} from './evaluation-result'
import { translate } from './translator'
import cloneDeep from 'lodash.clonedeep'
import type { LanguageFeatures, Meta } from './interpreter'
import type { InterpretResult } from './interpreter'

import type { Frame, FrameExecutionStatus } from './frames'
import { describeFrame } from './frames'
import { executeCallExpression } from './executor/executeCallExpression'
import { executeIfStatement } from './executor/executeIfStatement'
import didYouMean from 'didyoumean'
import { formatJikiObject } from './helpers'
import { executeBinaryExpression } from './executor/executeBinaryExpression'
import * as JikiTypes from './jikiObjects'
import { isBoolean, isNumber, isString } from './checks'

export type ExecutionContext = {
  state: Record<string, any>
  getCurrentTime: Function
  fastForward: Function
  evaluate: Function
  executeBlock: Function
  updateState: Function
  logicError: Function
}

export type ExternalFunction = {
  name: string
  func: Function
  description: string
  arity?: Arity
}

class ContinueFlowControlError extends Error {
  constructor(public location: Location, public lexeme: String) {
    super()
  }
}
class BreakFlowControlError extends Error {
  constructor(public location: Location) {
    super()
  }
}

export class Executor {
  private frames: Frame[] = []
  private frameTime: number = 0
  private location: Location | null = null
  private time: number = 0
  private totalLoopIterations = 0
  private maxTotalLoopIterations = 0
  private maxRepeatUntilGameOverIterations = 0

  private readonly globals = new Environment()
  private environment = this.globals

  // This tracks variables for each statement, so we can output
  // the changes in the frame descriptions
  private statementStartingVariablesLog: Record<string, any> = {}
  protected functionCallLog: Record<string, Record<any, number>> = {}
  protected functionCallStack: String[] = []

  constructor(
    private readonly sourceCode: string,
    private languageFeatures: LanguageFeatures,
    private externalFunctions: ExternalFunction[],
    private externalState: Record<string, any> = {}
  ) {
    for (let externalFunction of externalFunctions) {
      externalFunction = cloneDeep(externalFunction)
      const func = externalFunction.func

      // The first value passed to the function is the interpreter
      // so we discount that when working out the user's arity.
      // TODO: We need to consider default params here
      const arity = externalFunction.arity || [func.length - 1, func.length - 1]
      const call = (context: ExecutionContext, args: any[]) =>
        func(context, ...args.map((arg) => JikiTypes.unwrapJikiObject(arg)))

      const callable = {
        arity: arity,
        call: call,
      }

      this.globals.define(externalFunction.name, callable)
    }
    this.maxTotalLoopIterations = this.languageFeatures.maxTotalLoopIterations

    this.maxRepeatUntilGameOverIterations =
      this.languageFeatures.maxRepeatUntilGameOverIterations
  }

  public updateState(name: string, value: any) {
    this.externalState[name] = value
  }

  public logicError(message: string) {
    throw new LogicError(message)
  }

  // The Return boolean represents whether this has been successful
  // or created an error frame.
  private withExecutionContext(fn: Function): boolean {
    try {
      fn()
    } catch (error) {
      if (error instanceof ReturnValue) {
        // Remove the last frame and replace it with an error frame
        // This saves us having to pass the context down to where
        // the error is thrown.
        this.frames.pop()
        this.addFrame(
          error.location,
          'ERROR',
          undefined,
          this.buildError('UnexpectedReturnOutsideOfFunction', error.location)
        )
        return false
      }
      if (error instanceof ContinueFlowControlError) {
        // Remove the last frame and replace it with an error frame
        // This saves us having to pass the context down to where
        // the error is thrown.
        this.frames.pop()
        this.addFrame(
          error.location,
          'ERROR',
          undefined,
          this.buildError('UnexpectedContinueOutsideOfLoop', error.location, {
            lexeme: error.lexeme,
          })
        )
        return false
      }
      if (error instanceof BreakFlowControlError) {
        // Remove the last frame and replace it with an error frame
        // This saves us having to pass the context down to where
        // the error is thrown.
        this.frames.pop()
        this.addFrame(
          error.location,
          'ERROR',
          undefined,
          this.buildError('UnexpectedBreakOutsideOfLoop', error.location)
        )
        return false
      }
      throw error
    }
    return true
  }

  public execute(statements: Statement[]): InterpretResult {
    for (const statement of statements) {
      try {
        const res = this.withExecutionContext(() => {
          this.executeStatement(statement)
        })
        if (!res) {
          break
        }
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
      meta: this.generateMeta(statements),
    }
  }

  private generateMeta(statements): Meta {
    return {
      functionCallLog: this.functionCallLog,
      statements: statements,
      sourceCode: this.sourceCode,
    }
  }

  public evaluateSingleExpression(statement: Statement) {
    try {
      if (!(statement instanceof CallStatement)) {
        this.error('InvalidExpression', Location.unknown, {
          statement: statement,
        })
      }

      // TODO: Also start/end the statement management
      // Do not execute here, as this is the only expression without
      // a result that's allowed, so it needs to be called manually
      let result: EvaluationResultCallExpression | undefined
      this.withExecutionContext(() => {
        result = this.visitCallExpression(statement.expression)
      })

      return {
        value: result
          ? JikiTypes.unwrapJikiObject(result.jikiObject)
          : undefined,
        frames: this.frames,
        error: null,
        meta: this.generateMeta([statement]),
      }
    } catch (error) {
      if (isRuntimeError(error)) {
        if (
          error.location?.line === 1 &&
          (error.type === 'CouldNotFindFunction' ||
            error.type === 'CouldNotFindFunctionWithSuggestion')
        ) {
          const newError = this.buildError(
            'ExpectedFunctionNotFound',
            new Location(1, new Span(1, 0), new Span(1, 1)),
            { name: error.context.name }
          )

          this.addFrame(newError.location, 'ERROR', undefined, newError)
        } else if (
          error.location?.line === 1 &&
          (error.type === 'TooFewArguments' ||
            error.type === 'TooManyArguments')
        ) {
          const newError = this.buildError(
            'ExpectedFunctionHasWrongArguments',
            new Location(1, new Span(1, 0), new Span(1, 1)),
            { name: error.context.name }
          )

          this.addFrame(newError.location, 'ERROR', undefined, newError)
        } else {
          this.addFrame(
            this.location || error.location,
            'ERROR',
            undefined,
            error
          )
        }
        return {
          value: undefined,
          frames: this.frames,
          error: null,
          meta: this.generateMeta([statement]),
        }
      }

      throw error
    }
  }

  public executeBlock(
    statements: Statement[],
    blockEnvironment: Environment
  ): void {
    // Don't
    if (this.environment === blockEnvironment) {
      for (const statement of statements) {
        this.executeStatement(statement)
      }
      return
    }

    const previous: Environment = this.environment
    try {
      this.environment = blockEnvironment

      for (const statement of statements) {
        this.executeStatement(statement)
      }
    } finally {
      this.environment = previous
    }
  }
  public executeFrame<T extends EvaluationResult>(
    context: Statement | Expression,
    code: () => T
  ): T {
    this.location = context.location
    const result = code()
    this.addSuccessFrame(context.location, result, context)
    this.location = null
    return result as T
  }

  public visitCallStatement(statement: CallStatement): void {
    this.executeFrame(statement, () => {
      const result = this.visitCallExpression(
        statement.expression
      ) as EvaluationResultCallExpression

      /*if (statement.expression instanceof VariableLookupExpression)
        this.error('MissingParenthesesForFunctionCall', statement.location, {
          name: statement.expression.name.lexeme,
        })*/

      return {
        type: 'CallStatement',
        jikiObject: result.jikiObject,
        expression: result,
      }
    })
  }

  public visitSetVariableStatement(statement: SetVariableStatement): void {
    this.executeFrame<EvaluationResultSetVariableStatement>(statement, () => {
      this.guardDefinedName(statement.name)

      let value: EvaluationResultExpression
      try {
        value = this.evaluate(statement.value)
      } catch (e) {
        console.log(e)
        if (e instanceof RuntimeError && e.type == 'ExpressionIsNull') {
          this.error('CannotStoreNullFromFunction', statement.value.location)
        } else {
          throw e
        }
      }

      if (isCallable(value.jikiObject)) {
        this.error(
          'MissingParenthesesForFunctionCall',
          statement.value.location,
          {
            name: (statement.value as VariableLookupExpression).name.lexeme,
          }
        )
      }

      this.environment.define(statement.name.lexeme, value.jikiObject)

      return {
        type: 'SetVariableStatement',
        name: statement.name.lexeme,
        value: value,
        jikiObject: value.jikiObject,
      }
    })
  }

  public visitChangeVariableStatement(
    statement: ChangeVariableStatement
  ): void {
    this.executeFrame<EvaluationResultChangeVariableStatement>(
      statement,
      () => {
        // Ensure the variable exists
        this.lookupVariable(statement.name)

        if (isCallable(this.environment.get(statement.name))) {
          this.error('UnexpectedChangeOfFunction', statement.name.location, {
            name: statement.name.lexeme,
          })
        }

        let value: EvaluationResultExpression
        try {
          value = this.evaluate(statement.value)
        } catch (e) {
          if (e instanceof RuntimeError && e.type == 'ExpressionIsNull') {
            this.error('CannotStoreNullFromFunction', statement.value.location)
          } else {
            throw e
          }
        }

        // Update the underlying value
        this.environment.updateVariable(statement.name, value.jikiObject)

        const oldValue =
          this.statementStartingVariablesLog[statement.name.lexeme]

        return {
          type: 'ChangeVariableStatement',
          name: statement.name.lexeme,
          value: value,
          oldValue,
        }
      }
    )
  }

  public visitChangeElementStatement(statement: ChangeElementStatement): void {
    const obj = this.evaluate(statement.obj)
    if (obj.jikiObject instanceof JikiTypes.List) {
      return this.visitChangeListElementStatement(
        statement,
        obj as EvaluationResultListExpression
      )
    }
    if (obj.jikiObject instanceof JikiTypes.Dictionary) {
      return this.visitChangeDictionaryElementStatement(
        statement,
        obj as EvaluationResultDictionaryExpression
      )
    }
    this.error('InvalidChangeElementTarget', statement.obj.location)
  }

  public visitChangeDictionaryElementStatement(
    statement: ChangeElementStatement,
    dictionary: EvaluationResultDictionaryExpression
  ): void {
    this.executeFrame<EvaluationResultChangeElementStatement>(statement, () => {
      const field = this.evaluate(statement.field)
      this.verifyString(field.jikiObject, statement.field)
      const value = this.evaluate(statement.value)

      // Do the update
      const oldValue = dictionary.jikiObject[field.jikiObject.value]
      dictionary.jikiObject.value.set(field.jikiObject.value, value.jikiObject)

      return {
        type: 'ChangeElementStatement',
        obj: dictionary,
        field,
        value,
        oldValue,
      }
    })
  }

  public visitContinueStatement(statement: ContinueStatement): void {
    this.executeFrame<EvaluationResultContinueStatement>(statement, () => {
      return {
        type: 'ContinueStatement',
      }
    })

    throw new ContinueFlowControlError(
      statement.location,
      statement.keyword.lexeme
    )
  }

  public visitBreakStatement(statement: BreakStatement): void {
    this.executeFrame<EvaluationResultBreakStatement>(statement, () => {
      return {
        type: 'BreakStatement',
      }
    })

    throw new BreakFlowControlError(statement.location)
  }

  public visitChangeListElementStatement(
    statement: ChangeElementStatement,
    list: EvaluationResultListExpression
  ): void {
    this.executeFrame<EvaluationResultChangeElementStatement>(statement, () => {
      const index = this.evaluate(statement.field)
      this.verifyNumber(index.jikiObject, statement.field)
      this.guardOutofBoundsIndex(
        list.jikiObject,
        index.jikiObject,
        statement.field.location,
        'change'
      )

      const value = this.evaluate(statement.value)

      // Do the update
      const oldValue = list.jikiObject.value[index.jikiObject.value - 1]
      list.jikiObject.value[index.jikiObject.value - 1] = value.jikiObject

      return {
        type: 'ChangeElementStatement',
        obj: list,
        field: index,
        value,
        oldValue,
      }
    })
  }

  public visitIfStatement(statement: IfStatement): void {
    return executeIfStatement(this, statement)
  }

  public visitLogStatement(statement: LogStatement): void {
    this.executeFrame<EvaluationResultLogStatement>(statement, () => {
      const value = this.evaluate(statement.expression)
      return {
        type: 'LogStatement',
        expression: value,
        jikiObject: value.jikiObject,
      }
    })
  }

  public visitBlockStatement(statement: BlockStatement): void {
    // Change this to allow scoping
    // this.executeBlock(statement.statements, new Environment(this.environment))
    this.executeBlock(statement.statements, this.environment)
  }

  public visitFunctionStatement(statement: FunctionStatement): void {
    const func = new UserDefinedFunction(
      statement,
      this.environment,
      this.languageFeatures
    )
    this.environment.define(statement.name.lexeme, func)
  }

  public visitReturnStatement(statement: ReturnStatement): void {
    const evaluationResult = this.executeFrame<EvaluationResultReturnStatement>(
      statement,
      () => {
        if (statement.expression === null) {
          return {
            type: 'ReturnStatement',
            jikiObject: undefined,
          }
        }

        const value = this.evaluate(statement.expression)
        return {
          type: 'ReturnStatement',
          expression: value,
          jikiObject: value.jikiObject,
        }
      }
    )
    throw new ReturnValue(evaluationResult?.jikiObject, statement.location)
  }

  visitListExpression(expression: ListExpression): EvaluationResult {
    return {
      type: 'ListExpression',
      jikiObject: new JikiTypes.List(
        expression.elements.map((element) => this.evaluate(element).jikiObject)
      ),
    }
  }

  visitDictionaryExpression(
    expression: DictionaryExpression
  ): EvaluationResultDictionaryExpression {
    let records: Map<string, any> = new Map()

    for (const [key, value] of expression.elements.entries()) {
      const evalRes = this.evaluate(value)
      records.set(key, evalRes.jikiObject)
    }
    return {
      type: 'DictionaryExpression',
      jikiObject: new JikiTypes.Dictionary(records),
    }
  }

  private retrieveCounterVariableNameForLoop(
    statement:
      | ForeachStatement
      | RepeatStatement
      | RepeatForeverStatement
      | RepeatUntilGameOverStatement
  ): string | null {
    if (statement.counter == null) {
      return null
    }

    this.guardDefinedName(statement.counter)
    return statement.counter.lexeme
  }

  visitForeachStatement(statement: ForeachStatement): void {
    const iterable = this.evaluate(statement.iterable)
    if (
      !(iterable.jikiObject instanceof JikiTypes.List) &&
      !(iterable.jikiObject instanceof JikiTypes.String)
    ) {
      this.error('ForeachNotIterable', statement.iterable.location, {
        value: formatJikiObject(iterable.jikiObject),
      })
    }

    this.guardDefinedName(statement.elementName)

    const counterVariableName =
      this.retrieveCounterVariableNameForLoop(statement)

    if (iterable.jikiObject?.value.length === 0) {
      this.executeFrame<EvaluationResultForeachStatement>(statement, () => {
        return {
          type: 'ForeachStatement',
          index: 0,
          elementName: statement.elementName.lexeme,
          iterable,
        }
      })
    }

    this.executeLoop(() => {
      let index = 0
      for (let temporaryVariableValue of iterable.jikiObject.value) {
        // Wrap newly created string
        if (iterable.jikiObject instanceof JikiTypes.String) {
          temporaryVariableValue = new JikiTypes.String(temporaryVariableValue)
        }
        index += 1
        const temporaryVariableName = statement.elementName.lexeme
        this.environment.define(temporaryVariableName, temporaryVariableValue)

        this.executeFrame<EvaluationResultForeachStatement>(statement, () => {
          return {
            type: 'ForeachStatement',
            elementName: statement.elementName.lexeme,
            index,
            iterable,
            temporaryVariableName,
            temporaryVariableValue,
          }
        })

        this.executeLoopIteration(
          statement.body,
          index,
          temporaryVariableName,
          counterVariableName
        )
      }
    })
  }

  private executeLoop(body: () => void): void {
    try {
      body.call(this)
    } catch (e) {
      // If we've got a control flow error, don't do anything.
      if (e instanceof BreakFlowControlError) {
      }

      // Otherwise we have some error that shouldn't be handled here,
      // so get out of dodge!
      else {
        throw e
      }
    }
  }

  private executeLoopIteration(
    body: Statement[],
    iteration: number,
    temporaryVariableName: string | null,
    counterVariableName: string | null
  ): void {
    if (counterVariableName) {
      this.environment.define(
        counterVariableName,
        new JikiTypes.Number(iteration)
      )
    }

    try {
      this.executeBlock(body, this.environment)
    } catch (e) {
      // If we've got a control flow error, don't do anything.
      if (e instanceof ContinueFlowControlError) {
      }

      // Otherwise we have some error that shouldn't be handled here,
      // so get out of dodge!
      else {
        throw e
      }
    } finally {
      if (temporaryVariableName) {
        this.environment.undefine(temporaryVariableName)
      }
      if (counterVariableName) {
        this.environment.undefine(counterVariableName)
      }
    }
  }

  public visitRepeatStatement(statement: RepeatStatement): void {
    const countResult = this.evaluate(statement.count)
    const count = countResult.jikiObject
    const counterVariableName =
      this.retrieveCounterVariableNameForLoop(statement)

    if (!(count instanceof JikiTypes.Number)) {
      this.error('RepeatCountMustBeNumber', statement.count.location, {
        count,
      })
    }

    if (count.value < 0) {
      this.error('RepeatCountMustBeZeroOrGreater', statement.count.location, {
        count,
      })
    }

    if (count.value > this.maxTotalLoopIterations) {
      this.error('RepeatCountTooHigh', statement.count.location, {
        count,
        max: this.maxTotalLoopIterations,
      })
    }

    if (count.value == 0) {
      this.executeFrame<EvaluationResultRepeatStatement>(statement, () => {
        return {
          type: 'RepeatStatement',
          count: countResult,
          iteration: 0,
        }
      })
    }

    this.executeLoop(() => {
      let iteration = 0
      while (iteration < count.value) {
        iteration++
        this.guardInfiniteLoop(statement.keyword.location)

        if (counterVariableName) {
          this.environment.define(counterVariableName, iteration)
        }

        this.executeFrame<EvaluationResultRepeatStatement>(statement, () => {
          return {
            type: 'RepeatStatement',
            count: countResult,
            iteration,
          }
        })

        this.executeLoopIteration(
          statement.body,
          iteration,
          null,
          counterVariableName
        )

        // Delay repeat for things like animations
        this.time += this.languageFeatures.repeatDelay
      }
    })
  }

  public visitRepeatUntilGameOverStatement(
    statement: RepeatUntilGameOverStatement
  ): void {
    let iteration = 0 // Count is a guard against infinite looping
    const counterVariableName =
      this.retrieveCounterVariableNameForLoop(statement)

    this.executeLoop(() => {
      while (!this.externalState.gameOver) {
        iteration++
        if (iteration >= this.maxRepeatUntilGameOverIterations) {
          this.error('MaxIterationsReached', statement.keyword.location, {
            max: this.maxRepeatUntilGameOverIterations,
          })
        }

        this.guardInfiniteLoop(statement.keyword.location)
        this.executeLoopIteration(
          statement.body,
          iteration,
          null,
          counterVariableName
        )

        // Delay repeat for things like animations
        this.time += this.languageFeatures.repeatDelay
      }
    })
  }
  public visitRepeatForeverStatement(statement: RepeatForeverStatement): void {
    var iteration = 0 // Count is a guard against infinite looping
    const counterVariableName =
      this.retrieveCounterVariableNameForLoop(statement)

    this.executeLoop(() => {
      while (true) {
        iteration++
        if (iteration >= this.maxTotalLoopIterations) {
          this.error('InfiniteLoop', statement.keyword.location)
        }

        this.guardInfiniteLoop(statement.location)
        this.executeLoopIteration(
          statement.body,
          iteration,
          null,
          counterVariableName
        )

        // Delay repeat for things like animations
        this.time += this.languageFeatures.repeatDelay
      }
    })
  }

  public visitCallExpression(
    expression: CallExpression
  ): EvaluationResultCallExpression {
    return executeCallExpression(this, expression)
  }

  public visitLiteralExpression(
    expression: LiteralExpression
  ): EvaluationResultLiteralExpression {
    let jikiObject
    if (isBoolean(expression.value)) {
      jikiObject = new JikiTypes.Boolean(expression.value)
    } else if (isNumber(expression.value)) {
      jikiObject = new JikiTypes.Number(expression.value)
    } else if (isString(expression.value)) {
      jikiObject = new JikiTypes.String(expression.value)
    } else {
      // If this happens, we've gone really wrong somewhere!
      this.error('InvalidLiteralType', expression.location, {
        value: expression.value,
      })
    }
    return {
      type: 'LiteralExpression',
      jikiObject: jikiObject,
    }
  }

  public visitVariableLookupExpression(
    expression: VariableLookupExpression
  ): EvaluationResultVariableLookupExpression {
    const value = this.lookupVariable(expression.name)
    this.guardUncalledFunction(value, expression)

    return {
      type: 'VariableLookupExpression',
      name: expression.name.lexeme,
      jikiObject: value,
    }
  }

  public visitFunctionLookupExpression(
    expression: FunctionLookupExpression
  ): EvaluationResultFunctionLookupExpression {
    const value = this.lookupFunction(expression.name)
    return {
      type: 'FunctionLookupExpression',
      name: expression.name.lexeme,
      function: value,
      // This is needed so that the null guard doesn't
      // blow up upstream
      jikiObject: new JikiTypes.Boolean(true),
    }
  }

  public visitUnaryExpression(
    expression: UnaryExpression
  ): EvaluationResultUnaryExpression {
    const operand = this.evaluate(expression.operand)

    switch (expression.operator.type) {
      case 'NOT':
        this.verifyBoolean(operand.jikiObject, expression.operand)
        return {
          type: 'UnaryExpression',
          jikiObject: new JikiTypes.Boolean(!operand.jikiObject.value),
          right: operand,
        }
      case 'MINUS':
        this.verifyNumber(operand.jikiObject, expression.operand)
        return {
          type: 'UnaryExpression',
          jikiObject: new JikiTypes.Number(-operand.jikiObject.value),
          right: operand,
        }
    }

    // Unreachable.
    this.error('InvalidUnaryOperator', expression.operator.location, {
      expression,
    })
  }

  public visitBinaryExpression(
    expression: BinaryExpression
  ): EvaluationResultBinaryExpression {
    return executeBinaryExpression(this, expression)
  }

  public visitLogicalExpression(
    expression: LogicalExpression
  ): EvaluationResultLogicalExpression {
    if (expression.operator.type === 'OR') {
      const leftOr = this.evaluate(expression.left)
      this.verifyBoolean(leftOr.jikiObject, expression.left)

      let rightOr: EvaluationResult | undefined = undefined

      if (!leftOr.jikiObject.value) {
        rightOr = this.evaluate(expression.right)
        this.verifyBoolean(rightOr.jikiObject, expression.right)
      }

      const jikiObject = new JikiTypes.Boolean(
        leftOr.jikiObject.value || rightOr?.jikiObject.value
      )
      return {
        jikiObject,
        type: 'LogicalExpression',
        left: leftOr,
        right: rightOr,
        shortCircuited: rightOr === undefined,
      }
    }

    const leftAnd = this.evaluate(expression.left)
    this.verifyBoolean(leftAnd.jikiObject, expression.left)

    let rightAnd: EvaluationResult | undefined = undefined

    if (leftAnd.jikiObject.value) {
      rightAnd = this.evaluate(expression.right)
      this.verifyBoolean(rightAnd.jikiObject, expression.right)
    }

    const jikiObject = new JikiTypes.Boolean(
      leftAnd.jikiObject.value && rightAnd?.jikiObject.value
    )

    return {
      jikiObject: jikiObject,
      type: 'LogicalExpression',
      left: leftAnd,
      right: rightAnd,
      shortCircuited: rightAnd === undefined,
    }
  }

  public visitGroupingExpression(
    expression: GroupingExpression
  ): EvaluationResultGroupingExpression {
    const inner = this.evaluate(expression.inner)

    return {
      type: 'GroupingExpression',
      jikiObject: inner.jikiObject,
      inner,
    }
  }

  public visitGetElementExpression(
    expression: GetElementExpression
  ): EvaluationResultGetElementExpression {
    const obj = this.evaluate(expression.obj) as EvaluationResult
    if (obj.jikiObject instanceof JikiTypes.String) {
      return this.visitGetElementExpressionForString(
        expression,
        obj as EvaluationResultLiteralExpression
      )
    }
    if (
      obj.jikiObject instanceof JikiTypes.List ||
      obj.jikiObject instanceof JikiTypes.String
    ) {
      return this.visitGetElementExpressionForList(
        expression,
        obj as EvaluationResultListExpression
      )
    }
    if (obj.jikiObject instanceof JikiTypes.Dictionary) {
      return this.visitGetElementExpressionForDictionary(
        expression,
        obj as EvaluationResultDictionaryExpression
      )
    }

    this.error('InvalidIndexGetterTarget', expression.location, {
      expression,
      type: typeof obj.jikiObject,
    })
  }
  public visitGetElementExpressionForDictionary(
    expression: GetElementExpression,
    obj: EvaluationResultDictionaryExpression
  ): EvaluationResultGetElementExpression {
    const key = this.evaluate(expression.field)

    this.verifyString(key.jikiObject, expression.field)
    this.guardMissingDictionaryKey(
      obj.jikiObject,
      key.jikiObject,
      expression.location
    )

    const value = obj.jikiObject.value.get(key.jikiObject.value)

    return {
      type: 'GetElementExpression',
      obj: obj,
      expression: `${expression.obj.location.toCode(this.sourceCode)}[${
        key.jikiObject
      }]`,
      field: key,
      jikiObject: value,
    }
  }

  public visitGetElementExpressionForList(
    expression: GetElementExpression,
    obj: EvaluationResultListExpression
  ): EvaluationResultGetElementExpression {
    const idx = this.evaluate(expression.field)
    // TODO: Maybe a custom error message here about array indexes
    // or string indexes needing to be numbers?
    this.verifyNumber(idx.jikiObject, expression.field)

    this.guardOutofBoundsIndex(
      obj.jikiObject,
      idx.jikiObject,
      expression.field.location,
      'get'
    )

    const value = obj.jikiObject.value[idx.jikiObject.value - 1] // 0-index

    return {
      type: 'GetElementExpression',
      obj: obj,
      expression: `${expression.obj.location.toCode(this.sourceCode)}[${
        idx.jikiObject
      }]`,
      field: idx,
      jikiObject: value,
    }
  }

  public visitGetElementExpressionForString(
    expression: GetElementExpression,
    obj: EvaluationResultLiteralExpression
  ): EvaluationResultGetElementExpression {
    const idx = this.evaluate(expression.field)
    // TODO: Maybe a custom error message here about array indexes
    // or string indexes needing to be numbers?
    this.verifyNumber(idx.jikiObject, expression.field)

    this.guardOutofBoundsIndex(
      obj.jikiObject,
      idx.jikiObject,
      expression.field.location,
      'get'
    )

    // Extra using 0-index
    // Then wrap the new object
    const value = new JikiTypes.String(
      obj.jikiObject.value[idx.jikiObject.value - 1]
    )

    return {
      type: 'GetElementExpression',
      obj: obj,
      expression: `${expression.obj.location.toCode(this.sourceCode)}[${
        idx.jikiObject
      }]`,
      field: idx,
      jikiObject: value,
    }
  }

  public visitSetElementExpression(
    expression: SetElementExpression
  ): EvaluationResultSetElementExpression {
    const obj = this.evaluate(expression.obj)

    if (
      obj.jikiObject instanceof JikiTypes.List &&
      expression.field.type === 'NUMBER'
    ) {
      return this.visitSetElementExpressionForList(
        expression,
        obj as EvaluationResultListExpression
      )
    } else if (
      obj.jikiObject instanceof JikiTypes.Dictionary &&
      expression.field.type === 'STRING'
    ) {
      return this.visitSetElementExpressionForDictionary(
        expression,
        obj as EvaluationResultDictionaryExpression
      )
    }

    this.error('InvalidChangeElementTarget', expression.location, {
      expression,
      obj,
    })
  }

  public visitSetElementExpressionForList(
    expression: SetElementExpression,
    list: EvaluationResultListExpression
  ): EvaluationResultSetElementExpression {
    const value = this.evaluate(expression.value)
    list.jikiObject.value[expression.field.literal] = value.jikiObject

    return {
      type: 'SetElementExpression',
      obj: list,
      jikiObject: value.jikiObject,
      field: expression.field.literal,
      expression: `${expression.obj.location.toCode(this.sourceCode)}[${
        expression.field.lexeme
      }]`,
    }
  }

  public visitSetElementExpressionForDictionary(
    expression: SetElementExpression,
    dict: EvaluationResultDictionaryExpression
  ): EvaluationResultSetElementExpression {
    const value = this.evaluate(expression.value)
    dict.jikiObject.value[expression.field.literal] = value.jikiObject

    return {
      type: 'SetElementExpression',
      obj: dict,
      jikiObject: value.jikiObject,
      field: expression.field.literal,
      expression: `${expression.obj.location.toCode(this.sourceCode)}[${
        expression.field.lexeme
      }]`,
    }
  }

  private guardUncalledFunction(value: any, expr: Expression): void {
    if (isCallable(value)) {
      this.error('UnexpectedUncalledFunction', expr.location, {
        name: (expr as VariableLookupExpression).name.lexeme,
      })
    }
  }

  public verifyLiteral(value: JikiTypes.JikiObject, expr: Expression): void {
    if (value instanceof JikiTypes.Number) return
    if (value instanceof JikiTypes.String) return
    if (value instanceof JikiTypes.Boolean) return

    this.guardUncalledFunction(value, expr)

    if (value instanceof JikiTypes.List) {
      this.error('ListsCannotBeCompared', expr.location, {
        value: formatJikiObject(value),
      })
    }
    this.error('IncomparableTypes', expr.location, {
      value: formatJikiObject(value),
    })
  }

  public verifyNumber(value: JikiTypes.JikiObject, expr: Expression): void {
    if (value instanceof JikiTypes.Number) return

    this.guardUncalledFunction(value, expr)

    this.error('OperandMustBeNumber', expr.location, {
      value: formatJikiObject(value),
    })
  }
  public verifyString(value: JikiTypes.JikiObject, expr: Expression): void {
    if (value instanceof JikiTypes.String) return
    this.guardUncalledFunction(value, expr)

    this.error('OperandMustBeString', expr.location, {
      value: formatJikiObject(value),
    })
  }
  public verifyBoolean(value: JikiTypes.JikiObject, expr: Expression): void {
    if (value instanceof JikiTypes.Boolean) return

    this.error('OperandMustBeBoolean', expr.location, {
      value: formatJikiObject(value),
    })
  }

  public executeStatement(statement: Statement): void {
    if (this.time > this.languageFeatures.maxTotalExecutionTime) {
      const location = new Location(
        statement.location.line,
        new Span(
          statement.location.relative.begin,
          statement.location.relative.begin + 1
        ),
        new Span(
          statement.location.absolute.begin,
          statement.location.absolute.begin + 1
        )
      )
      this.error('MaxTotalExecutionTimeReached', location)
    }

    // Store a clone of the values so that any changes do not affect this
    this.statementStartingVariablesLog = cloneDeep(this.environment.variables())

    const method = `visit${statement.type}`
    this[method](statement)
  }

  public evaluate(expression: Expression): EvaluationResultExpression {
    const method = `visit${expression.type}`
    const evaluationResult = this[method](expression)
    this.guardNull(evaluationResult.jikiObject, expression)
    return evaluationResult
  }

  private lookupVariable(name: Token): any {
    let variable = this.environment.get(name)
    if (variable !== undefined) {
      return variable
    }

    // Check where we've got a global
    if (this.globals.inScope(name)) {
      // If we have then we're using a function as a variable
      // (ie we've missed the paranetheses)
      if (isCallable(this.globals.get(name))) {
        this.error('MissingParenthesesForFunctionCall', name.location, {
          name: name.lexeme,
        })
      }

      // Otherwise we're accessing a global variable when we shouldn't
      this.error('VariableNotAccessibleInFunction', name.location, {
        name: name.lexeme,
      })
    }

    // Otherwise we have no idea what this is
    this.error('VariableNotDeclared', name.location, {
      name: name.lexeme,
      didYouMean: {
        variable: didYouMean(
          name.lexeme,
          Object.keys(this.environment.variables())
        ),
        function: didYouMean(
          name.lexeme,
          Object.keys(this.environment.functions())
        ),
      },
    })
  }

  public lookupFunction(name: Token): any {
    let fn = this.environment.get(name)
    if (fn === undefined) {
      fn = this.globals.get(name)
    }
    if (fn === undefined) {
      this.error('CouldNotFindFunction', name.location, {
        name: name.lexeme,

        didYouMean: {
          variable: didYouMean(
            name.lexeme,
            Object.keys(this.environment.variables())
          ),
          function: didYouMean(
            name.lexeme,
            Object.keys(this.environment.functions())
          ),
        },
      })
    }
    return fn
  }

  private guardOutofBoundsIndex(
    obj: JikiTypes.List | JikiTypes.String,
    idx: JikiTypes.Number,
    location: Location,
    getOrChange: 'get' | 'change'
  ) {
    if (idx.value == 0) {
      this.error('IndexIsZero', location)
    }
    if (idx.value <= obj.value.length) {
      return
    }

    // Set to IndexOutOfBoundsInGet or IndexOutOfBoundsInSet
    // by capitalzing the first letter of get or set
    const errorType:
      | 'IndexOutOfBoundsInGet'
      | 'IndexOutOfBoundsInChange' = `IndexOutOfBoundsIn${
      getOrChange.charAt(0).toUpperCase() + getOrChange.slice(1)
    }`

    const dataType = obj instanceof JikiTypes.List ? 'list' : 'string'
    this.error(errorType, location, {
      index: idx.value,
      length: obj.value.length,
      dataType,
    })
  }

  private guardMissingDictionaryKey(
    dictionary: JikiTypes.Dictionary,
    key: JikiTypes.String,
    location: Location
  ) {
    if (dictionary.value.has(key.value)) {
      return
    }

    this.error('MissingKeyInDictionary', location, {
      key: formatJikiObject(key),
    })
  }

  private guardDefinedName(name: Token) {
    if (this.environment.inScope(name)) {
      if (isCallable(this.environment.get(name))) {
        this.error('FunctionAlreadyDeclared', name.location, {
          name: name.lexeme,
        })
      }
      this.error('VariableAlreadyDeclared', name.location, {
        name: name.lexeme,
      })
    }
  }

  private guardInfiniteLoop(loc: Location) {
    this.totalLoopIterations++

    if (this.totalLoopIterations > this.maxTotalLoopIterations) {
      this.error('MaxIterationsReached', loc, {
        max: this.maxTotalLoopIterations,
      })
    }
  }
  private guardNull(value, guiltyExpression) {
    if (value !== null && value !== undefined) {
      return
    }
    this.error('ExpressionIsNull', guiltyExpression.location)
  }

  public addSuccessFrame(
    location: Location | null,
    result: EvaluationResult,
    context?: Statement | Expression
  ): void {
    this.addFrame(location, 'SUCCESS', result, undefined, context)
  }

  public addErrorFrme(
    location: Location | null,
    error: RuntimeError,
    context?: Statement | Expression
  ): void {
    this.addFrame(location, 'ERROR', undefined, error, context)
  }

  private addFrame(
    location: Location | null,
    status: FrameExecutionStatus,
    result?: EvaluationResult,
    error?: RuntimeError,
    context?: Statement | Expression
  ): void {
    if (location == null) location = Location.unknown

    const frame: Frame = {
      code: location.toCode(this.sourceCode),
      line: location.line,
      status,
      result,
      error,
      priorVariables: this.statementStartingVariablesLog,
      variables: this.environment.variables(),
      functions: this.environment.functions(),
      time: this.frameTime,
      description: '',
      context: context,
    }
    const descriptionContext = {
      functionDescriptions: this.externalFunctions.reduce((acc, fn) => {
        acc[fn.name] = fn.description
        return acc
      }, {}),
    }

    frame.description = describeFrame(frame, descriptionContext)

    this.frames.push(frame)

    this.time++
    this.frameTime = this.time
  }

  public addFunctionCallToLog(name: string, args: any[]) {
    const unwrappedArgs = JikiTypes.unwrapJikiObject(args)
    this.functionCallLog[name] ||= {}
    this.functionCallLog[name][JSON.stringify(unwrappedArgs)] ||= 0
    this.functionCallLog[name][JSON.stringify(unwrappedArgs)] += 1
  }

  public addFunctionToCallStack(name: string, expression: CallExpression) {
    this.functionCallStack.push(name)

    if (this.functionCallStack.filter((n) => n == name).length > 5) {
      this.error('InfiniteRecursion', expression.location)
    }
  }

  public popCallStack() {
    this.functionCallStack.pop()
  }

  public getExecutionContext(): ExecutionContext {
    return {
      state: this.externalState,
      fastForward: (n: number) => {
        this.time += n
      },
      getCurrentTime: () => this.time,
      executeBlock: this.executeBlock.bind(this),
      evaluate: this.evaluate.bind(this),
      updateState: this.updateState.bind(this),
      logicError: this.logicError.bind(this),
    }
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
    context = JikiTypes.unwrapJikiObject(context)

    let message
    if (type == 'LogicError') {
      message = context.message
    } else {
      message = translate(`error.runtime.${type}`, context)
    }

    return new RuntimeError(message, location, type, context)
  }
}
