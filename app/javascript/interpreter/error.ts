import { Location } from './location'

export type DisabledLanguageFeatureErrorType =
  | 'ExcludeListViolation'
  | 'IncludeListViolation'

export type SyntaxErrorType =
  | 'GenericSyntaxError'
  | 'UnknownCharacter'
  | 'MissingCommaAfterParameters'
  | 'MissingDoToStartBlock'
  | 'MissingEndAfterBlock'
  | 'MissingConditionAfterIf'
  | 'MissingDoubleQuoteToStartString'
  | 'MissingDoubleQuoteToTerminateString'
  | 'MissingFieldNameOrIndexAfterLeftBracket'
  | 'MissingRightBracketAfterExpression'
  | 'MissingRightParenthesisAfterExpression'
  | 'MissingRightBraceToTerminatePlaceholder'
  | 'MissingBacktickToTerminateTemplateLiteral'
  | 'MissingExpression'
  | 'InvalidAssignmentTarget'
  | 'ExceededMaximumNumberOfParameters'
  | 'MissingEndOfLine'
  | 'MissingFunctionName'
  | 'InvalidFunctionName'
  | 'MissingLeftParenthesisAfterFunctionName'
  | 'MissingLeftParenthesisAfterFunctionCall'
  | 'MissingParameterName'
  | 'MissingRightParenthesisAfterParameters'
  | 'MissingLeftParenthesisAfterWhile'
  | 'MissingRightParenthesisAfterWhileCondition'
  | 'MissingWhileBeforeDoWhileCondition'
  | 'MissingLeftParenthesisAfterDoWhile'
  | 'MissingRightParenthesisAfterDoWhileCondition'
  | 'MissingVariableName'
  | 'InvalidNumericVariableName'
  | 'MissingConstantName'
  | 'MissingToAfterVariableNameToInitializeValue'
  | 'MissingToAfterVariableNameToChangeValue'
  | 'MissingLeftParenthesisBeforeIfCondition'
  | 'MissingRightParenthesisAfterIfCondition'
  | 'MissingDoToStartFunctionBody'
  | 'MissingDoToStartFunctionBody'
  | 'MissingDoToStartIfBody'
  | 'MissingDoToStartElseBody'
  | 'MissingDoAfterRepeatStatementCondition'
  | 'MissingDoAfterWhileStatementCondition'
  | 'MissingLeftParenthesisAfterForeach'
  | 'MissingLetInForeachCondition'
  | 'MissingElementNameAfterForeach'
  | 'MissingOfAfterElementNameInForeach'
  | 'MissingRightParenthesisAfterForeachElement'
  | 'MissingRightBracketAfterFieldNameOrIndex'
  | 'MissingRightParenthesisAfterFunctionCall'
  | 'MissingRightParenthesisAfterExpression'
  | 'MissingRightParenthesisAfterExpressionWithPotentialTypo'
  | 'MissingRightBracketAfterListElements'
  | 'MissingRightBraceAfterMapElements'
  | 'MissingWithBeforeParameters'
  | 'MissingStringAsKey'
  | 'MissingColonAfterKey'
  | 'MissingFieldNameOrIndexAfterOpeningBracket'
  | 'InvalidTemplateLiteral'
  | 'NumberEndsWithDecimalPoint'
  | 'NumberWithMultipleDecimalPoints'
  | 'NumberContainsAlpha'
  | 'NumberStartsWithZero'
  | 'UnexpectedElseWithoutIf'
  | 'UnexpectedSpaceInIdentifier'
  | 'DuplicateParameterName'
  | 'MissingTimesInRepeat'
  | 'UnexpectedEqualsForAssignment'
  | 'UnexpectedEqualsForEquality'
  | 'InvalidNestedFunction'
  | 'UnexpectedChainedEquality'
  | 'MiscapitalizedKeyword'
  | 'PointlessStatement'
  | 'PotentialMissingParenthesesForFunctionCall'
  | 'MissingEachAfterFor'

export type SemanticErrorType =
  | 'TopLevelReturn'
  | 'VariableUsedInOwnInitializer'
  | 'DuplicateVariableName'
  | 'CannotAssignToConstant'
  | 'InvalidPostfixOperand'

export type RuntimeErrorType =
  | 'CouldNotFindFunction'
  | 'CouldNotEvaluateFunction'
  | 'CouldNotFindFunction'
  | 'CouldNotFindFunctionWithSuggestion'
  | 'MissingParenthesesForFunctionCall'
  | 'InvalidExpression'
  | 'RepeatCountMustBeNumber'
  | 'RepeatCountMustBeGreaterThanZero'
  | 'RepeatCountTooHigh'
  | 'NonCallableTarget'
  | 'InfiniteLoop'
  | 'TooFewArguments'
  | 'TooManyArguments'
  | 'InvalidNumberOfArgumentsWithOptionalArguments'
  | 'InvalidUnaryOperator'
  | 'InvalidBinaryExpression'
  | 'LogicError'
  | 'OperandMustBeBoolean'
  | 'OperandMustBeNumber'
  | 'OperandsMustBeTwoNumbersOrTwoStrings'
  | 'InvalidIndexGetterTarget'
  | 'InvalidChangeElementTarget'
  | 'UnexpectedEqualsForEquality'
  | 'VariableAlreadyDeclared'
  | 'VariableNotDeclared'
  | 'VariableNotAccessibleInFunction'
  | 'UnexpectedUncalledFunction'
  | 'FunctionAlreadyDeclared'
  | 'UnexpectedChangeOfFunction'
  | 'FunctionCallTypeMismatch'
  | 'UnexpectedReturnOutsideOfFunction'
  | 'ExpectedFunctionNotFound'
  | 'ExpectedFunctionHasWrongArguments'
  | 'MaxIterationsReached'
  | 'InfiniteRecursion'
  | 'CannotStoreNullFromFunction'
  | 'CannotStoreNull'
  | 'ExpressionIsNull'
<<<<<<< HEAD
  | 'ForeachNotIterable'
=======
  | 'IndexIsZero'
  | 'IndexOutOfBoundsInGet'
  | 'IndexOutOfBoundsInChange'
>>>>>>> 062e6ffa9 (More guards)

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

export class LogicError extends Error {}

type FunctionCallTypeMismatchErrorContext = {
  argIdx: number
  expectedType: string
  actualType: string
}
export class FunctionCallTypeMismatchError {
  constructor(public context: FunctionCallTypeMismatchErrorContext) {}
}

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
