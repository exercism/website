import type { TokenType } from './token'

export type EvaluationResultVariableStatement = {
  type: 'VariableStatement'
  value: any
  name: string
  data?: Record<string, any>
}

export type EvaluationResultTernaryExpression = {
  type: 'TernaryExpression'
  value: any
  condition: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultUpdateExpression = {
  type: 'UpdateExpression'
  operand: any
  operator: any
  value: any
  newValue: any
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

export type EvaluationResultExpressionStatement = {
  type: 'ExpressionStatement'
  value: any
  expression: EvaluationResult
  data?: Record<string, any>
}

export type EvaluationResultLogicalExpression = {
  type: 'LogicalExpression'
  value: any
  left: EvaluationResult
  right?: EvaluationResult
  operator: TokenType
  shortCircuited: boolean
  data?: Record<string, any>
}

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

export type EvaluationResultAssignExpression = {
  type: 'AssignExpression'
  name: string
  operator: TokenType
  value: any
  newValue: any
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

export type EvaluationResultArrayExpression = {
  type: 'ArrayExpression'
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
  callee: EvaluationResult
  args: EvaluationResult[]
  data?: Record<string, any>
}

export type EvaluationResult =
  | EvaluationResultVariableStatement
  | EvaluationResultUpdateExpression
  | EvaluationResultConstantStatement
  | EvaluationResultTernaryExpression
  | EvaluationResultIfStatement
  | EvaluationResultExpressionStatement
  | EvaluationResultForeachStatement
  | EvaluationResultReturnStatement
  | EvaluationResultLiteralExpression
  | EvaluationResultArrayExpression
  | EvaluationResultDictionaryExpression
  | EvaluationResultVariableExpression
  | EvaluationResultCallExpression
  | EvaluationResultLogicalExpression
  | EvaluationResultBinaryExpression
  | EvaluationResultUnaryExpression
  | EvaluationResultGroupingExpression
  | EvaluationResultAssignExpression
  | EvaluationResultGetExpression
  | EvaluationResultSetExpression
  | EvaluationResultTemplateTextExpression
  | EvaluationResultTemplatePlaceholderExpression
  | EvaluationResultTemplateLiteralExpression
