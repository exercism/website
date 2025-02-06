import { Callable } from './functions'
import { ChangeListElementStatement } from './statement'
import type { TokenType } from './token'

export type EvaluationResultCallStatement = {
  type: 'CallStatement'
  expression: EvaluationResultCallExpression
  resultingValue: any
  data?: Record<string, any>
}

export type EvaluationResultChangeListElementStatement = {
  type: 'ChangeListElementStatement'
  list: EvaluationResult
  index: EvaluationResult
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

export type EvaluationResultForeachStatement = {
  type: 'ForeachStatement'
  elementName: string
  iterable: EvaluationResult
  temporaryVariableName?: any
  temporaryVariablValue?: any
  resultingValue?: any
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

export type EvaluationResultGetExpression = {
  type: 'GetExpression'
  resultingValue: any
  obj: any
  field: any
  expression: string
  data?: Record<string, any>
}

export type EvaluationResultSetExpression = {
  type: 'SetExpression'
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
  | EvaluationResultChangeListElementStatement
  | EvaluationResultConstantStatement
  | EvaluationResultIfStatement
  | EvaluationResultCallStatement
  | EvaluationResultForeachStatement
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
  | EvaluationResultGetExpression
  | EvaluationResultSetExpression
  | EvaluationResultTemplateTextExpression
  | EvaluationResultTemplatePlaceholderExpression
  | EvaluationResultTemplateLiteralExpression
