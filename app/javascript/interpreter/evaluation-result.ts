import { Callable } from './functions'
import { ChangeElementStatement } from './statement'
import type { TokenType } from './token'

export type EvaluationResultCallStatement = {
  type: 'CallStatement'
  expression: EvaluationResultCallExpression
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultChangeElementStatement = {
  type: 'ChangeElementStatement'
  obj: EvaluationResult
  field: EvaluationResult
  value: EvaluationResult
  oldValue: any
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultChangeVariableStatement = {
  type: 'ChangeVariableStatement'
  name: string
  value: EvaluationResult
  oldValue: any
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultContinueStatement = {
  type: 'ContinueStatement'
  resultingValue?: undefined
  data?: Record<string, any>
}

export type EvaluationResultBreakStatement = {
  type: 'BreakStatement'
  resultingValue?: undefined
  data?: Record<string, any>
}

export type EvaluationResultForeachStatement = {
  type: 'ForeachStatement'
  elementName: string
  iterable: EvaluationResult
  index: number
  temporaryVariableName?: any
  temporaryVariableValue?: any
  resultingValue?: undefined
  data?: Record<string, any>
}

export type EvaluationResultIfStatement = {
  type: 'IfStatement'
  condition: EvaluationResult
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultLogStatement = {
  type: 'LogStatement'
  expression: EvaluationResult
  resultingValue: any
}

export type EvaluationResultRepeatStatement = {
  type: 'RepeatStatement'
  count: EvaluationResult
  iteration: number
  resultingValue?: undefined
  data?: Record<string, any>
}

export type EvaluationResultReturnStatement = {
  type: 'ReturnStatement'
  expression?: EvaluationResult
  resultingValue?: any
  data?: Record<string, any>
}

export type EvaluationResultSetVariableStatement = {
  type: 'SetVariableStatement'
  name: string
  value: EvaluationResultExpression
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultLogicalExpression = {
  type: 'LogicalExpression'
  resultingValue: any
  left: EvaluationResult
  right?: EvaluationResult
  shortCircuited: boolean
  data?: Record<string, any>
}

export type EvaluationResultFullyEvaluatedLogicalExpression =
  EvaluationResultLogicalExpression & { right: EvaluationResult }

export type EvaluationResultBinaryExpression = {
  type: 'BinaryExpression'
  resultingValue: any
  left: EvaluationResult
  right: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultUnaryExpression = {
  type: 'UnaryExpression'
  resultingValue: any
  right: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultGroupingExpression = {
  type: 'GroupingExpression'
  resultingValue: any
  inner: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultLiteralExpression = {
  type: 'LiteralExpression'
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultVariableLookupExpression = {
  type: 'VariableLookupExpression'
  name: string
  resultingValue: any
  data?: Record<string, any>
}
export type EvaluationResultFunctionLookupExpression = {
  type: 'FunctionLookupExpression'
  name: string
  function: Callable
  resultingValue?: any
  data?: Record<string, any>
}

export type EvaluationResultConstantStatement = {
  type: 'ConstantStatement'
  resultingValue: any
  name: string
  data?: Record<string, any>
}

export type EvaluationResultGetElementExpression = {
  type: 'GetElementExpression'
  resultingValue: any
  obj: any
  field: any
  expression: string
  data?: Record<string, any>
}

export type EvaluationResultSetElementExpression = {
  type: 'SetElementExpression'
  resultingValue: any
  obj: any
  field: any
  expression: string
  data?: Record<string, any>
}

export type EvaluationResultListExpression = {
  type: 'ListExpression'
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultDictionaryExpression = {
  type: 'DictionaryExpression'
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultTemplateTextExpression = {
  type: 'TemplateTextExpression'
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultTemplatePlaceholderExpression = {
  type: 'TemplatePlaceholderExpression'
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultTemplateLiteralExpression = {
  type: 'TemplateLiteralExpression'
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultCallExpression = {
  type: 'CallExpression'
  resultingValue: any
  callee: EvaluationResultVariableLookupExpression
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
  | EvaluationResultConstantStatement
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
  | EvaluationResultTemplateTextExpression
  | EvaluationResultTemplatePlaceholderExpression
  | EvaluationResultTemplateLiteralExpression
