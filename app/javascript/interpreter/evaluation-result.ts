import { Callable } from './functions'
import * as JikiTypes from './jikiTypes'
import { ChangeElementStatement } from './statement'
import type { TokenType } from './token'

export type EvaluationResultCallStatement = {
  type: 'CallStatement'
  expression: EvaluationResultCallExpression
  jikiObject: JikiTypes.JikiObject
  data?: Record<string, any>
}

export type EvaluationResultChangeElementStatement = {
  type: 'ChangeElementStatement'
  obj: EvaluationResult
  field: EvaluationResult
  value: EvaluationResult
  oldValue: JikiTypes.JikiObject
  jikiObject?: undefined
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
  temporaryVariableName?: any
  temporaryVariableValue?: JikiTypes.JikiObject
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
  jikiObject: JikiTypes.JikiObject
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
  right: EvaluationResult
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

export type EvaluationResultCallExpression = {
  type: 'CallExpression'
  jikiObject: JikiTypes.JikiObject
  callee:
    | EvaluationResultVariableLookupExpression
    | EvaluationResultFunctionLookupExpression
  args: EvaluationResult[]
  data?: Record<string, any>
}

export type EvaluationResult =
  | EvaluationResultStatement
  | EvaluationResultExpression

export type EvaluationResultStatement =
  | EvaluationResultLogStatement
  | EvaluationResultSetVariableStatement
  | EvaluationResultChangeVariableStatement
  | EvaluationResultChangeElementStatement
  | EvaluationResultContinueStatement
  | EvaluationResultBreakStatement
  | EvaluationResultIfStatement
  | EvaluationResultCallStatement
  | EvaluationResultForeachStatement
  | EvaluationResultRepeatStatement
  | EvaluationResultReturnStatement

export type EvaluationResultExpression =
  | EvaluationResultLiteralExpression
  | EvaluationResultListExpression
  | EvaluationResultDictionaryExpression
  | EvaluationResultVariableLookupExpression
  | EvaluationResultCallExpression
  | EvaluationResultLogicalExpression
  | EvaluationResultBinaryExpression
  | EvaluationResultUnaryExpression
  | EvaluationResultGroupingExpression
  | EvaluationResultGetElementExpression
  | EvaluationResultSetElementExpression
