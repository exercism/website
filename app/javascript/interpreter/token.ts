import { Location } from './location'
import { SomethingWithLocation } from './interpreter'

export type TokenType =
  // Single-character tokens
  | 'BACKTICK'
  | 'COLON'
  | 'COMMA'
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

  // Keywords
  | 'AND'
  | 'CHANGE'
  | 'DO'
  | 'ELSE'
  | 'END'
  | 'FALSE'
  | 'FOR'
  | 'FOREACH'
  | 'FUNCTION'
  | 'IF'
  | 'IN'
  | 'NULL'
  | 'IN'
  | 'OR'
  | 'REPEAT'
  | 'REPEAT_FOREVER'
  | 'REPEAT_UNTIL_GAME_OVER'
  | 'RETURN'
  | 'SET'
  | 'TO'
  | 'TIMES'
  | 'TRUE'
  // | 'WHILE'
  | 'WITH'

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
