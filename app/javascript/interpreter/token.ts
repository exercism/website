import { Location } from './location'
import { SomethingWithLocation } from './interpreter'

const StatementKeywordTokens = [
  'BREAK',
  'CHANGE',
  'CLASS',
  'CONSTRUCTOR',
  'CONTINUE',
  'NEXT',
  'FOR',
  'FUNCTION',
  'IF',
  'LOG',
  'METHOD',
  'PRIVATE',
  'PROPERTY',
  'PUBLIC',
  'REPEAT',
  'REPEAT_FOREVER',
  'REPEAT_UNTIL_GAME_OVER',
  'RETURN',
  'SET',
  'THIS',
  // 'WHILE'
] as const

const OtherKeywordTokens = [
  'AND',
  'DO',
  'ELSE',
  'END',
  'FALSE',
  'EACH',
  'IN',
  'NULL',
  'NEW',
  'OR',
  'TO',
  'TIMES',
  'TRUE',
  'WITH',
  'INDEXED',
  'BY',
]

export const KeywordTokens = [...StatementKeywordTokens, ...OtherKeywordTokens]

// Convert the array of strings into a union type
type StatementKeywordTokenType = (typeof StatementKeywordTokens)[number]
type OtherKeywordTokenType = (typeof OtherKeywordTokens)[number]
export type KeywordTokenType = StatementKeywordTokenType | OtherKeywordTokenType

export type TokenType =
  | KeywordTokenType

  // Single-character tokens
  | 'BACKTICK'
  | 'COLON'
  | 'COMMA'
  | 'DOT'
  | 'LEFT_BRACE'
  | 'LEFT_BRACKET'
  | 'LEFT_PAREN'
  | 'MINUS'
  | 'PERCENT'
  | 'PLUS'
  | 'QUESTION_MARK'
  | 'RIGHT_BRACE'
  | 'RIGHT_BRACKET'
  | 'RIGHT_PAREN'
  | 'SLASH'
  | 'STAR'
  | 'NOT'

  // One, two or three character tokens.
  | 'DOLLAR_LEFT_BRACE'
  | 'GREATER_EQUAL'
  | 'GREATER'
  | 'LESS_EQUAL'
  | 'LESS'
  | 'EQUAL'

  // Literals
  | 'IDENTIFIER'
  | 'NUMBER'
  | 'STRING'
  | 'TEMPLATE_LITERAL_TEXT'

  // Grouping tokens
  | 'EQUALITY'
  | 'INEQUALITY'

  // Invisible tokens
  | 'EOL' // End of statement
  | 'EOF' // End of file

export type Token = SomethingWithLocation & {
  type: TokenType
  lexeme: string
  literal: any
}
