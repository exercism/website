import { Callable } from './functions'
import * as JikiTypes from './jikiObjects'
import { ChangeElementStatement } from './statement'
import type { TokenType } from './token'

export type EvaluationResultFunctionCallStatement = {
  type: 'FunctionCallStatement'
  expression: EvaluationResultFunctionCallExpression
  jikiObject: JikiTypes.JikiObject
  data?: Record<string, any>
}
export type EvaluationResultMethodCallStatement = {
  type: 'MethodCallStatement'
  expression: EvaluationResultMethodCallExpression
  jikiObject: JikiTypes.JikiObject
  data?: Record<string, any>
}

export type EvaluationResultChangeElementStatement = {
  type: 'ChangeElementStatement'
  object: EvaluationResult
  field: EvaluationResult
  value: EvaluationResult
  oldValue: any
  jikiObject?: undefined
  data?: Record<string, any>
}
export type EvaluationResultChangePropertyStatement = {
  type: 'ChangePropertyStatement'
  object: EvaluationResult
  value: EvaluationResult
  jikiObject?: undefined
  oldValue?: JikiTypes.JikiObject
  data?: Record<string, any>
}

export type EvaluationResultChangeVariableStatement = {
  type: 'ChangeVariableStatement'
  name: string
  value: EvaluationResult
  oldValue: JikiTypes.JikiObject
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultContinueStatement = {
  type: 'ContinueStatement'
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultBreakStatement = {
  type: 'BreakStatement'
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultForeachStatement = {
  type: 'ForeachStatement'
  elementName: string
  iterable: EvaluationResult
  index: number
  temporaryVariableValue?: JikiTypes.JikiObject
  secondTemporaryVariableValue?: JikiTypes.JikiObject
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultIfStatement = {
  type: 'IfStatement'
  condition: EvaluationResult
  jikiObject: JikiTypes.Boolean
  data?: Record<string, any>
}

export type EvaluationResultLogStatement = {
  type: 'LogStatement'
  expression: EvaluationResult
  jikiObject: JikiTypes.JikiObject
}

export type EvaluationResultRepeatStatement = {
  type: 'RepeatStatement'
  count: EvaluationResult
  iteration: number
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultReturnStatement = {
  type: 'ReturnStatement'
  expression?: EvaluationResult
  jikiObject?: JikiTypes.JikiObject
  data?: Record<string, any>
}

export type EvaluationResultSetVariableStatement = {
  type: 'SetVariableStatement'
  name: string
  value: EvaluationResultExpression
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultSetPropertyStatement = {
  type: 'SetPropertyStatement'
  property: string
  value: EvaluationResult
  jikiObject?: undefined
  data?: Record<string, any>
}

export type EvaluationResultLogicalExpression = {
  type: 'LogicalExpression'
  left: EvaluationResult
  right?: EvaluationResult
  shortCircuited: boolean
  jikiObject: JikiTypes.Boolean
  data?: Record<string, any>
}

export type EvaluationResultFullyEvaluatedLogicalExpression =
  EvaluationResultLogicalExpression & { right: EvaluationResult }

export type EvaluationResultBinaryExpression = {
  type: 'BinaryExpression'
  jikiObject: JikiTypes.Primitive
  left: EvaluationResult
  right: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultUnaryExpression = {
  type: 'UnaryExpression'
  jikiObject: JikiTypes.Primitive
  operand: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultGroupingExpression = {
  type: 'GroupingExpression'
  jikiObject: JikiTypes.JikiObject
  inner: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultLiteralExpression = {
  type: 'LiteralExpression'
  jikiObject: JikiTypes.Literal
  data?: Record<string, any>
}

export type EvaluationResultThisExpression = {
  type: 'ThisExpression'
  jikiObject: JikiTypes.Instance
  data?: Record<string, any>
}

export type EvaluationResultVariableLookupExpression = {
  type: 'VariableLookupExpression'
  name: string
  jikiObject: JikiTypes.JikiObject
  data?: Record<string, any>
}
export type EvaluationResultFunctionLookupExpression = {
  type: 'FunctionLookupExpression'
  name: string
  function: Callable
  jikiObject?: JikiTypes.Boolean
  data?: Record<string, any>
}

export type EvaluationResultGetElementExpression = {
  type: 'GetElementExpression'
  // Can be a string, list, or dictionary
  obj:
    | EvaluationResultLiteralExpression
    | EvaluationResultListExpression
    | EvaluationResultDictionaryExpression
  field: EvaluationResult
  expression: string
  jikiObject: JikiTypes.JikiObject
  data?: Record<string, any>
}

export type EvaluationResultSetElementExpression = {
  type: 'SetElementExpression'
  obj: EvaluationResultListExpression | EvaluationResultDictionaryExpression
  field: EvaluationResult
  expression: string
  jikiObject: JikiTypes.JikiObject
  data?: Record<string, any>
}

export type EvaluationResultListExpression = {
  type: 'ListExpression'
  jikiObject: JikiTypes.List
  data?: Record<string, any>
}

export type EvaluationResultDictionaryExpression = {
  type: 'DictionaryExpression'
  jikiObject: JikiTypes.Dictionary
  data?: Record<string, any>
}

export type EvaluationResultFunctionCallExpression = {
  type: 'FunctionCallExpression'
  jikiObject: JikiTypes.JikiObject
  callee:
    | EvaluationResultVariableLookupExpression
    | EvaluationResultFunctionLookupExpression
  args: EvaluationResult[]
  data?: Record<string, any>
}
export type EvaluationResultMethodCallExpression = {
  type: 'MethodCallExpression'
  jikiObject: JikiTypes.JikiObject
  object: EvaluationResult
  method: JikiTypes.Method
  args: EvaluationResult[]
  data?: Record<string, any>
}
export type EvaluationResultClassLookupExpression = {
  type: 'ClassLookupExpression'
  name: string
  class: JikiTypes.Class
  jikiObject: JikiTypes.Boolean
  data?: Record<string, any>
}
export type EvaluationResultInstantiationExpression = {
  type: 'InstantiationExpression'
  jikiObject: JikiTypes.Instance
  className: EvaluationResultClassLookupExpression
  args: EvaluationResult[]
  data?: Record<string, any>
}
export type EvaluationResultGetterExpression = {
  type: 'GetterExpression'
  jikiObject: JikiTypes.JikiObject
  object: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResult =
  | EvaluationResultStatement
  | EvaluationResultExpression

export type EvaluationResultStatement =
  | EvaluationResultLogStatement
  | EvaluationResultSetVariableStatement
  | EvaluationResultChangeVariableStatement
  | EvaluationResultSetPropertyStatement
  | EvaluationResultChangeElementStatement
  | EvaluationResultContinueStatement
  | EvaluationResultBreakStatement
  | EvaluationResultIfStatement
  | EvaluationResultFunctionCallStatement
  | EvaluationResultMethodCallStatement
  | EvaluationResultForeachStatement
  | EvaluationResultRepeatStatement
  | EvaluationResultReturnStatement
  | EvaluationResultChangePropertyStatement

export type EvaluationResultExpression =
  | EvaluationResultLiteralExpression
  | EvaluationResultListExpression
  | EvaluationResultDictionaryExpression
  | EvaluationResultVariableLookupExpression
  | EvaluationResultClassLookupExpression
  | EvaluationResultFunctionCallExpression
  | EvaluationResultLogicalExpression
  | EvaluationResultBinaryExpression
  | EvaluationResultUnaryExpression
  | EvaluationResultGroupingExpression
  | EvaluationResultGetElementExpression
  | EvaluationResultSetElementExpression
  | EvaluationResultInstantiationExpression
  | EvaluationResultGetterExpression
  | EvaluationResultMethodCallExpression
