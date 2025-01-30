import { ReturnValue, UserDefinedFunction, isCallable } from './functions'
import { isArray, isBoolean, isNumber, isObject, isString } from './checks'
import { Environment } from './environment'
import {
  FunctionCallTypeMismatchError,
  RuntimeError,
  type RuntimeErrorType,
  isRuntimeError,
  LogicError,
} from './error'
import {
  BinaryExpression,
  CallExpression,
  Expression,
  FunctionLookupExpression,
  GetExpression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  SetExpression,
  UnaryExpression,
  UpdateExpression,
  VariableLookupExpression,
} from './expression'
import { Location, Span } from './location'
import {
  BlockStatement,
  ExpressionStatement,
  FunctionStatement,
  IfStatement,
  RepeatStatement,
  RepeatUntilGameOverStatement,
  ReturnStatement,
  Statement,
  SetVariableStatement,
  ChangeVariableStatement,
  RepeatForeverStatement,
} from './statement'
import type { Token } from './token'
import type { EvaluationResult } from './evaluation-result'
import { translate } from './translator'
import cloneDeep from 'lodash.clonedeep'
import type { LanguageFeatures, SomethingWithLocation } from './interpreter'
import type { InterpretResult } from './interpreter'

import type { Frame, FrameExecutionStatus } from './frames'
import { describeFrame } from './frames'
import { executeCallExpression } from './executor/executeCallExpression'
import didYouMean from 'didyoumean'
import { formatLiteral } from './helpers'

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
}

export class Executor {
  private frames: Frame[] = []
  private frameTime: number = 0
  private location: Location | null = null
  private time: number = 0
  private totalLoopIterations = 0 // TODO: Every time a loop iterates, use this to guard
  private maxTotalLoopIterations = 0 // TODO: Every time a loop iterates, use this to guard
  private maxRepeatUntilGameOverIterations = 0

  private readonly globals = new Environment()
  private environment = this.globals

  // This tracks variables for each statement, so we can output
  // the changes in the frame descriptions
  private statementStartingVariables: Record<string, any> = {}
  protected functionCallLog: Record<string, Record<any, number>> = {}

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
      const arity = () => [func.length - 1, func.length - 1]
      const call = (context: ExecutionContext, args: any[]) =>
        func(context, ...args)

      const callable = {
        arity: arity,
        call: call,
      }

      this.globals.define(externalFunction.name, callable)
    }
    this.maxTotalLoopIterations =
      this.languageFeatures.maxTotalLoopIterations || 100

    this.maxRepeatUntilGameOverIterations =
      this.languageFeatures.maxRepeatUntilGameOverIterations || 100
  }

  public updateState(name: string, value: any) {
    this.externalState[name] = value
  }

  public logicError(message: string) {
    throw new LogicError(message)
  }

  public execute(statements: Statement[]): InterpretResult {
    for (const statement of statements) {
      try {
        this.executeStatement(statement)
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
          break
        }
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
      functionCallLog: this.functionCallLog,
    }
  }

  public evaluateSingleExpression(statement: Statement) {
    try {
      if (!(statement instanceof ExpressionStatement)) {
        this.error('InvalidExpression', Location.unknown, {
          statement: statement,
        })
      }

      // TODO: Also start/end the statement management
      const result = this.evaluate(statement.expression)
      return {
        value: result.value,
        frames: this.frames,
        error: null,
        functionCallLog: this.functionCallLog,
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
          functionCallLog: this.functionCallLog,
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

  private executeFrame<T>(
    context: Statement | Expression,
    code: () => EvaluationResult
  ): T {
    this.location = context.location
    const result = code()
    this.addFrame(context.location, 'SUCCESS', result, undefined, context)
    this.location = null
    return result.value
  }

  public visitExpressionStatement(statement: ExpressionStatement): void {
    this.executeFrame(statement, () => {
      const result = this.evaluate(statement.expression)

      if (statement.expression instanceof VariableLookupExpression)
        this.error('MissingParenthesesForFunctionCall', statement.location, {
          name: statement.expression.name.lexeme,
        })

      return result
    })
  }

  public visitSetVariableStatement(statement: SetVariableStatement): void {
    this.executeFrame(statement, () => {
      if (this.environment.inScope(statement.name)) {
        if (isCallable(this.environment.get(statement.name))) {
          this.error('FunctionAlreadyDeclared', statement.name.location, {
            name: statement.name.lexeme,
          })
        }
        this.error('VariableAlreadyDeclared', statement.location, {
          name: statement.name.lexeme,
        })
      }
      const value = this.evaluate(statement.initializer).value
      if (isCallable(value)) {
        this.error(
          'MissingParenthesesForFunctionCall',
          statement.initializer.location,
          {
            name: (statement.initializer as VariableLookupExpression).name
              .lexeme,
          }
        )
      }

      this.environment.define(statement.name.lexeme, value)

      return {
        type: 'SetVariableStatement',
        name: statement.name.lexeme,
        value: value,
      }
    })
  }

  public visitChangeVariableStatement(
    statement: ChangeVariableStatement
  ): void {
    this.executeFrame(statement, () => {
      // Ensure the variable exists
      this.lookupVariable(statement.name)

      if (isCallable(this.environment.get(statement.name))) {
        this.error('UnexpectedChangeOfFunction', statement.name.location, {
          name: statement.name.lexeme,
        })
      }

      const value = this.evaluate(statement.value)

      this.updateVariable(statement.name, value.value, statement)

      const oldValue = this.statementStartingVariables[statement.name.lexeme]

      return {
        type: 'ChangeVariableStatement',
        name: statement.name.lexeme,
        oldValue,
        newValue: value,
      }
    })
  }

  public visitIfStatement(statement: IfStatement): void {
    const conditionResult = this.executeFrame(statement, () => {
      const result = this.evaluate(statement.condition)
      return {
        type: 'IfStatement',
        value: result.value,
        condition: result,
      }
    })

    if (conditionResult) {
      this.executeStatement(statement.thenBranch)
      return
    }

    if (statement.elseBranch === null) return
    this.executeStatement(statement.elseBranch!)
  }

  public visitRepeatStatement(statement: RepeatStatement): void {
    let count = this.executeFrame(statement, () =>
      this.evaluate(statement.count)
    )

    if (!isNumber(count)) {
      this.error('RepeatCountMustBeNumber', statement.count.location, {
        count,
      })
    }

    if (count < 1) {
      this.error('RepeatCountMustBeGreaterThanZero', statement.count.location, {
        count,
      })
    }

    if (count > this.maxTotalLoopIterations) {
      this.error('RepeatCountTooHigh', statement.count.location, {
        count,
        max: this.maxTotalLoopIterations,
      })
    }

    while (count > 0) {
      this.guardInfiniteLoop(statement.location)
      this.executeBlock(statement.body, this.environment)
      count--

      // Delay repeat for things like animations
      this.time += this.languageFeatures.repeatDelay
    }
  }

  public visitRepeatUntilGameOverStatement(
    statement: RepeatUntilGameOverStatement
  ): void {
    let count = 0 // Count is a guard against infinite looping

    while (!this.externalState.gameOver) {
      this.guardInfiniteLoop(statement.location)
      if (count >= this.maxRepeatUntilGameOverIterations) {
        const errorLoc = new Location(
          statement.location.line,
          statement.location.relative,
          new Span(
            statement.location.absolute.begin,
            statement.location.absolute.begin + 22
          )
        )
        this.error('MaxIterationsReached', errorLoc, {
          max: this.maxRepeatUntilGameOverIterations,
        })
      }

      this.guardInfiniteLoop(statement.location)
      this.executeBlock(statement.body, this.environment)
      count++
    }
  }
  public visitRepeatForeverStatement(statement: RepeatForeverStatement): void {
    var count = 0 // Count is a guard against infinite looping

    while (true) {
      this.guardInfiniteLoop(statement.location)
      if (count >= 1000) {
        const errorLoc = new Location(
          statement.location.line,
          statement.location.relative,
          new Span(
            statement.location.absolute.begin,
            statement.location.absolute.begin + 14
          )
        )
        this.error('InfiniteLoop', errorLoc)
      }

      this.guardInfiniteLoop(statement.location)
      this.executeBlock(statement.body, this.environment)
      count++
    }
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
    const evaluationResult = this.executeFrame<EvaluationResult>(
      statement,
      () => {
        return {
          type: 'ReturnStatement',
          value:
            statement.value === null
              ? undefined
              : this.evaluate(statement.value),
        }
      }
    )
    throw new ReturnValue(evaluationResult?.value, statement.location)
  }

  // visitForeachStatement(statement: ForeachStatement): void {
  //   const iterable = this.evaluate(statement.iterable)
  //   if (!isArray(iterable.value) || iterable.value?.length === 0) {
  //     this.executeFrame<any>(statement, () => {
  //       return {
  //         type: 'ForeachStatement',
  //         value: undefined,
  //         iterable,
  //         elementName: statement.elementName.lexeme,
  //       }
  //     })
  //   }

  //   for (const value of iterable.value) {
  //     this.executeFrame<any>(statement, () => {
  //       return {
  //         type: 'ForeachStatement',
  //         value,
  //         iterable,
  //         elementName: statement.elementName.lexeme,
  //       }
  //     })

  //     // TODO: Think about this. Currently it creates a new environment for each loop iteration
  //     // with the element in. But that's maybe not what we want as it'll be a new scope
  //     // and the rest of Jiki is currently not scoped on a block basis.
  //     // Consider a `finally` to unset the variable instead?
  //     const loopEnvironment = new Environment(this.environment)
  //     loopEnvironment.define(statement.elementName.lexeme, value)
  //     this.executeBlock(statement.body, loopEnvironment)
  //   }
  // }

  // public visitWhileStatement(statement: WhileStatement): void {
  //   while (
  //     this.executeFrame(statement, () => this.evaluate(statement.condition))
  //   )
  //     this.executeBlock(statement.body, this.environment)
  // }

  // public visitDoWhileStatement(statement: DoWhileStatement): void {
  //   do {
  //     this.executeBlock(statement.body, this.environment)
  //   } while (
  //     this.executeFrame<boolean>(statement, () =>
  //       this.evaluate(statement.condition)
  //     )
  //   )
  // }

  // visitTemplateLiteralExpression(
  //   expression: TemplateLiteralExpression
  // ): EvaluationResult {
  //   return {
  //     type: 'TemplateLiteralExpression',
  //     value: expression.parts
  //       .map((part) => this.evaluate(part).value.toString())
  //       .join(''),
  //   }
  // }

  // visitTemplatePlaceholderExpression(
  //   expression: TemplatePlaceholderExpression
  // ): EvaluationResult {
  //   return {
  //     type: 'TemplatePlaceholderExpression',
  //     value: this.evaluate(expression.inner).value,
  //   }
  // }

  // visitTemplateTextExpression(
  //   expression: TemplateTextExpression
  // ): EvaluationResult {
  //   return {
  //     type: 'TemplateTextExpression',
  //     value: expression.text.literal,
  //   }
  // }

  // visitArrayExpression(expression: ArrayExpression): EvaluationResult {
  //   return {
  //     type: 'ArrayExpression',
  //     value: expression.elements.map((element) => this.evaluate(element).value),
  //   }
  // }

  // visitDictionaryExpression(
  //   expression: DictionaryExpression
  // ): EvaluationResult {
  //   let dict: Record<string, any> = {}

  //   for (const [key, value] of expression.elements)
  //     dict[key] = this.evaluate(value).value

  //   return { type: 'DictionaryExpression', value: dict }
  // }

  public visitCallExpression(expression: CallExpression): EvaluationResult {
    return executeCallExpression(this, expression)
  }

  public visitLiteralExpression(
    expression: LiteralExpression
  ): EvaluationResult {
    return {
      type: 'LiteralExpression',
      value: expression.value,
    }
  }

  public visitVariableLookupExpression(
    expression: VariableLookupExpression
  ): EvaluationResult {
    const value = this.lookupVariable(expression.name)
    return {
      type: 'VariableLookupExpression',
      name: expression.name.lexeme,
      value,
    }
  }

  public visitFunctionLookupExpression(
    expression: FunctionLookupExpression
  ): EvaluationResult {
    const value = this.lookupFunction(expression.name)
    return {
      type: 'FunctionLookupExpression',
      name: expression.name.lexeme,
      value,
    }
  }

  public visitUnaryExpression(expression: UnaryExpression): EvaluationResult {
    const operand = this.evaluate(expression.operand)

    switch (expression.operator.type) {
      case 'NOT':
        this.verifyBooleanOperand(operand.value, expression.operator.location)
        return {
          type: 'UnaryExpression',
          operator: expression.operator.type,
          value: !operand.value,
          right: operand,
        }
      case 'MINUS':
        this.verifyNumberOperand(expression.operator, operand.value)
        return {
          type: 'UnaryExpression',
          operator: expression.operator.type,
          value: -operand.value,
          right: operand,
        }
    }

    // Unreachable.
    this.error('InvalidUnaryOperator', expression.operator.location, {
      expression,
    })
  }

  public visitBinaryExpression(expression: BinaryExpression): EvaluationResult {
    const leftResult = this.evaluate(expression.left)
    const rightResult = this.evaluate(expression.right)

    const result: EvaluationResult = {
      type: 'BinaryExpression',
      value: undefined,
      operator: expression.operator.type,
      left: leftResult,
      right: rightResult,
    }

    switch (expression.operator.type) {
      case 'INEQUALITY':
        // TODO: throw error when types are not the same?
        return { ...result, value: leftResult.value !== rightResult.value }
      case 'EQUALITY':
        // TODO: throw error when types are not the same?
        return {
          ...result,
          value: leftResult.value === rightResult.value,
        }
      case 'GREATER':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )
        return {
          ...result,
          value: leftResult.value > rightResult.value,
        }
      case 'GREATER_EQUAL':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )
        return {
          ...result,
          value: leftResult.value >= rightResult.value,
        }
      case 'LESS':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )
        return {
          ...result,
          value: leftResult.value < rightResult.value,
        }
      case 'LESS_EQUAL':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )
        return {
          ...result,
          value: leftResult.value <= rightResult.value,
        }
      case 'MINUS':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )

        const minusValue = leftResult.value - rightResult.value
        const minusValue2DP = Math.round(minusValue * 100) / 100

        return {
          ...result,
          value: minusValue2DP,
        }
      //> binary-plus
      case 'PLUS':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )

        const plusValue = leftResult.value + rightResult.value
        const plusValue2DP = Math.round(plusValue * 100) / 100

        return {
          ...result,
          value: plusValue2DP,
        }

        if (isNumber(leftResult.value) && isNumber(rightResult.value)) {
          const plusValue = leftResult.value + rightResult.value
          const plusValue2DP = Math.round(plusValue * 100) / 100

          return {
            ...result,
            value: plusValue2DP,
          }
        }
      /*if (isString(left.value) && isString(right.value))
          return {
            ...result,
            value: left.value + right.value,
          }

        this.error(
          'OperandsMustBeTwoNumbersOrTwoStrings',
          expression.operator.location,
          {
            left,
            right,
          }
        )*/

      case 'SLASH':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )
        const slashValue = leftResult.value / rightResult.value
        const slashValue2DP = Math.round(slashValue * 100) / 100
        return {
          ...result,
          value: slashValue2DP,
        }
      case 'STAR':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )

        const starValue = leftResult.value * rightResult.value
        const starValue2DP = Math.round(starValue * 100) / 100
        return {
          ...result,
          value: starValue2DP,
        }
      case 'PERCENT':
        this.verifyNumberOperands(
          expression.operator,
          expression.left,
          expression.right,
          leftResult.value,
          rightResult.value
        )

        return {
          ...result,
          value: leftResult.value % rightResult.value,
        }
      case 'EQUAL':
        this.error('UnexpectedEqualsForEquality', expression.location, {
          expression,
        })
    }

    this.error('InvalidBinaryExpression', expression.location, { expression })
  }

  public visitLogicalExpression(
    expression: LogicalExpression
  ): EvaluationResult {
    if (expression.operator.type === 'OR') {
      const leftOr = this.evaluate(expression.left)
      this.verifyBooleanOperand(leftOr.value, expression.operator.location)

      let rightOr: EvaluationResult | undefined = undefined

      if (!leftOr.value) {
        rightOr = this.evaluate(expression.right)
        this.verifyBooleanOperand(rightOr.value, expression.operator.location)
      }

      return {
        value: leftOr.value || rightOr?.value,
        type: 'LogicalExpression',
        left: leftOr,
        right: rightOr,
        operator: expression.operator.type,
        shortCircuited: rightOr === undefined,
      }
    }

    const leftAnd = this.evaluate(expression.left)
    this.verifyBooleanOperand(leftAnd.value, expression.operator.location)

    let rightAnd: EvaluationResult | undefined = undefined

    if (leftAnd.value) {
      rightAnd = this.evaluate(expression.right)
      this.verifyBooleanOperand(rightAnd.value, expression.operator.location)
    }

    return {
      value: leftAnd.value && rightAnd?.value,
      type: 'LogicalExpression',
      left: leftAnd,
      right: rightAnd,
      operator: expression.operator.type,
      shortCircuited: rightAnd === undefined,
    }
  }

  public visitGroupingExpression(
    expression: GroupingExpression
  ): EvaluationResult {
    const inner = this.evaluate(expression.inner)

    return {
      type: 'GroupingExpression',
      value: inner.value,
      inner,
    }
  }

  public visitUpdateExpression(expression: UpdateExpression): EvaluationResult {
    let value
    let newValue

    if (expression.operand instanceof VariableLookupExpression) {
      value = this.lookupVariable(expression.operand.name)
      this.verifyNumberOperand(expression.operator, value)

      newValue =
        expression.operator.type === 'PLUS_PLUS' ? value + 1 : value - 1

      this.updateVariable(expression.operand.name, newValue, expression.operand)

      return {
        type: 'UpdateExpression',
        operand: expression.operand,
        operator: expression.operator.type,
        value,
        newValue,
      }
    } else if (expression.operand instanceof GetExpression) {
      const obj = this.evaluate(expression.operand.obj)

      if (isObject(obj.value) && expression.operand.field.type === 'STRING') {
        value = obj.value[expression.operand.field.literal]
      } else if (
        isArray(obj.value) &&
        expression.operand.field.type === 'NUMBER'
      ) {
        value = obj.value[expression.operand.field.literal]
      }

      this.verifyNumberOperand(expression.operator, value)
      newValue =
        expression.operator.type === 'PLUS_PLUS' ? value + 1 : value - 1
      obj.value[expression.operand.field.literal] = newValue

      return {
        type: 'UpdateExpression',
        operand: expression.operand,
        operator: expression.operator.type,
        value,
        newValue,
      }
    }

    throw new Error('InvalidUpdateExpression')
  }

  private updateVariable(
    name: Token,
    newValue: undefined,
    expression: Expression
  ) {
    // This will exception if the variable doesn't exist
    this.lookupVariable(name)

    this.environment.updateVariable(name, newValue)
  }

  public visitGetExpression(expression: GetExpression): EvaluationResult {
    const obj = this.evaluate(expression.obj)

    if (isObject(obj.value) && expression.field.type === 'STRING') {
      // TODO: consider if we want to throw an error when the field does not exist or return null
      return {
        type: 'GetExpression',
        obj: obj,
        expression: `${expression.obj.location.toCode(this.sourceCode)}[${
          expression.field.lexeme
        }]`,
        field: expression.field.literal,
        value: obj.value[expression.field.literal],
      }
    }

    if (isArray(obj.value) && expression.field.type === 'NUMBER') {
      // TODO: consider if we want to throw an error when the index does not exist or return null
      return {
        type: 'GetExpression',
        obj: obj,
        expression: `${expression.obj.location.toCode(this.sourceCode)}[${
          expression.field.lexeme
        }]`,
        field: expression.field.literal,
        value: obj.value[expression.field.literal],
      }
    }

    this.error('InvalidIndexGetterTarget', expression.location, {
      expression,
      obj,
    })
  }

  public visitSetExpression(expression: SetExpression): EvaluationResult {
    const obj = this.evaluate(expression.obj)

    if (
      (isObject(obj.value) && expression.field.type === 'STRING') ||
      (isArray(obj.value) && expression.field.type === 'NUMBER')
    ) {
      const value = this.evaluate(expression.value)
      obj.value[expression.field.literal] = value.value

      return {
        type: 'SetExpression',
        obj,
        value,
        field: expression.field.literal,
        expression: `${expression.obj.location.toCode(this.sourceCode)}[${
          expression.field.lexeme
        }]`,
      }
    }

    this.error('InvalidIndexSetterTarget', expression.location, {
      expression,
      obj,
    })
  }

  private verifyNumberOperand(operator: Token, operand: any): void {
    if (isNumber(operand)) return

    this.error('OperandMustBeNumber', operator.location, { operand })
  }

  private verifyNumberOperands(
    operator: Token,
    leftExpr: Expression,
    rightExpr: Expression,
    leftValue: EvaluationResult,
    rightValue: EvaluationResult
  ): void {
    const leftIsNumber = isNumber(leftValue)
    const rightIsNumber = isNumber(rightValue)
    if (leftIsNumber && rightIsNumber) {
      return
    }

    let value
    let eroneousExpr
    let location
    if (leftIsNumber) {
      value = rightValue
      eroneousExpr = rightExpr
      location = Location.between(operator, rightExpr)
    } else {
      value = leftValue
      eroneousExpr = leftExpr
      location = Location.between(leftExpr, operator)
    }

    if (isCallable(value)) {
      this.error('UnexpectedUncalledFunction', eroneousExpr.location, {
        name: eroneousExpr.name,
      })
    }

    this.error('OperandsMustBeNumbers', location, {
      operator: operator.lexeme,
      side: leftIsNumber ? 'right' : 'left',
      value: formatLiteral(value),
    })
  }

  private verifyBooleanOperand(operand: any, location: Location): void {
    if (isBoolean(operand)) return

    this.error('OperandMustBeBoolean', location, { operand })
  }

  public executeStatement(statement: Statement): void {
    this.statementStartingVariables = cloneDeep(this.environment.variables())

    const method = `visit${statement.type}`
    this[method](statement)
  }

  public evaluate(expression: Expression): EvaluationResult {
    const method = `visit${expression.type}`
    return this[method](expression)
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
    let variable = this.environment.get(name)
    if (variable === undefined) {
      variable = this.globals.get(name)
    }
    if (variable === undefined) {
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
    return variable
  }

  private guardInfiniteLoop(loc: Location) {
    this.totalLoopIterations++

    if (this.totalLoopIterations > 1000) {
      this.error('InfiniteLoop', loc)
    }
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
      priorVariables: this.statementStartingVariables,
      variables: this.environment.variables(),
      functions: this.environment.functions(),
      time: this.frameTime,
      description: '',
      context: context,
    }
    frame.description = describeFrame(frame, this.externalFunctions)

    this.frames.push(frame)

    this.time++
    this.frameTime = this.time
  }

  public addFunctionCallToLog(name: string, args: any[]) {
    this.functionCallLog[name] ||= {}
    this.functionCallLog[name][JSON.stringify(args)] ||= 0
    this.functionCallLog[name][JSON.stringify(args)] += 1
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
    let message
    if (type == 'LogicError') {
      message = context.message
    } else {
      message = translate(`error.runtime.${type}`, context)
    }

    return new RuntimeError(message, location, type, context)
  }
}
