import { ChangeListElementStatement } from './statement'
import type { TokenType } from './token'

export type EvaluationResultLogStatement = {
  type: 'LogStatement'
  value: any
}
export type EvaluationResultSetVariableStatement = {
  type: 'SetVariableStatement'
  value: any
  name: string
  data?: Record<string, any>
}

export type EvaluationResultIfStatement = {
  type: 'IfStatement'
  value: any
  condition: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultReturnStatement = {
  type: 'ReturnStatement'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultForeachStatement = {
  type: 'ForeachStatement'
  value?: any
  elementName: string
  iterable: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultCallStatement = {
  type: 'CallStatement'
  value: any
  expression: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultLogicalExpression = {
  type: 'LogicalExpression'
  value: any
  left: EvaluationResult
  right?: EvaluationResult
  operator: Token
  shortCircuited: boolean
  data?: Record<string, any>
}

export type EvaluationResultFullyEvaluatedLogicalExpression =
  EvaluationResultLogicalExpression & { right: EvaluationResult }

export type EvaluationResultBinaryExpression = {
  type: 'BinaryExpression'
  value: any
  left: EvaluationResult
  right: EvaluationResult
  operator: TokenType
  data?: Record<string, any>
}

export type EvaluationResultUnaryExpression = {
  type: 'UnaryExpression'
  value: any
  right: EvaluationResult
  operator: TokenType
  data?: Record<string, any>
}

export type EvaluationResultGroupingExpression = {
  type: 'GroupingExpression'
  value: any
  inner: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultLiteralExpression = {
  type: 'LiteralExpression'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultVariableExpression = {
  type: 'VariableExpression'
  value: any
  name: string
  data?: Record<string, any>
}

export type EvaluationResultConstantStatement = {
  type: 'ConstantStatement'
  value: any
  name: string
  data?: Record<string, any>
}

export type EvaluationResultChangeVariableStatement = {
  type: 'ChangeVariableStatement'
  name: string
  oldValue: any
  value: any
  data?: Record<string, any>
}

export type EvaluationResultChangeListElementStatement = {
  type: 'ChangeListElementStatement'
  oldValue: any
  value: any
  data?: Record<string, any>
}

export type EvaluationResultGetExpression = {
  type: 'GetExpression'
  value: any
  obj: any
  field: any
  expression: string
  data?: Record<string, any>
}

export type EvaluationResultSetExpression = {
  type: 'SetExpression'
  value: any
  obj: any
  field: any
  expression: string
  data?: Record<string, any>
}

export type EvaluationResultListExpression = {
  type: 'ListExpression'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultDictionaryExpression = {
  type: 'DictionaryExpression'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultTemplateTextExpression = {
  type: 'TemplateTextExpression'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultTemplatePlaceholderExpression = {
  type: 'TemplatePlaceholderExpression'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultTemplateLiteralExpression = {
  type: 'TemplateLiteralExpression'
  value: any
  data?: Record<string, any>
}

export type EvaluationResultCallExpression = {
  type: 'CallExpression'
  value: any
  callee: EvaluationResultVariableExpression
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
  | EvaluationResultVariableExpression
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
