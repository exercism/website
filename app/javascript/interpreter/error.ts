import { Location } from './location'

export type DisabledLanguageFeatureErrorType =
  | 'ExcludeListViolation'
  | 'IncludeListViolation'

export type SemanticErrorType =
  | 'TopLevelReturn'
  | 'VariableUsedInOwnInitializer'
  | 'DuplicateVariableName'
  | 'CannotAssignToConstant'
  | 'InvalidPostfixOperand'

export type RuntimeErrorType =
  | 'CouldNotFindValueWithName'
  | 'CouldNotEvaluateFunction'
  | 'CouldNotFindFunctionWithName'
  | 'CouldNotFindFunctionWithNameSuggestion'
  | 'MissingParenthesesForFunctionCall'
  | 'InvalidExpression'
  | 'RepeatCountMustBeNumber'
  | 'RepeatCountMustBeGreaterThanZero'
  | 'NonCallableTarget'
  | 'InfiniteLoop'
  | 'TooFewArguments'
  | 'TooManyArguments'
  | 'InvalidNumberOfArgumentsWithOptionalArguments'
  | 'InvalidUnaryOperator'
  | 'InvalidBinaryExpression'
  | 'LogicError'
  | 'OperandMustBeBoolean'
  | 'OperandsMustBeBooleans'
  | 'OperandMustBeNumber'
  | 'OperandsMustBeNumbers'
  | 'OperandsMustBeTwoNumbersOrTwoStrings'
  | 'InvalidIndexGetterTarget'
  | 'InvalidIndexSetterTarget'

export type StaticErrorType =
  | DisabledLanguageFeatureErrorType
  | SemanticErrorType
  | SyntaxErrorType

export type ErrorType = StaticErrorType | RuntimeErrorType

export type ErrorCategory =
  | 'SyntaxError'
  | 'SemanticError'
  | 'DisabledLanguageFeatureError'
  | 'RuntimeError'

export abstract class FrontendError<T extends ErrorType> extends Error {
  constructor(
    public message: string,
    public location: Location | null,
    public type: T,
    public context?: any
  ) {
    super(message)
  }

  public get category() {
    return this.constructor.name
  }
}

export type StaticError = SyntaxError | SemanticError | RuntimeError

export class SyntaxError extends FrontendError<SyntaxErrorType> {}

export class SemanticError extends FrontendError<SemanticErrorType> {}

export class DisabledLanguageFeatureError extends FrontendError<DisabledLanguageFeatureErrorType> {}

export class RuntimeError extends FrontendError<RuntimeErrorType> {}

export function isStaticError(obj: any): obj is StaticError {
  return (
    isSyntaxError(obj) ||
    isSemanticError(obj) ||
    isDisabledLanguageFeatureError(obj)
  )
}

export function isSyntaxError(obj: any): obj is SyntaxError {
  return obj instanceof SyntaxError
}

export function isSemanticError(obj: any): obj is SemanticError {
  return obj instanceof SemanticError
}

export function isDisabledLanguageFeatureError(
  obj: any
): obj is DisabledLanguageFeatureError {
  return obj instanceof DisabledLanguageFeatureError
}

export function isRuntimeError(obj: any): obj is RuntimeError {
  return obj instanceof RuntimeError
}
