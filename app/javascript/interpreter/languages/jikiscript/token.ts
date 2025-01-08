import { Location } from '../../location'

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

  // One, two or three character tokens.
  | 'NOT'
  | 'DOLLAR_LEFT_BRACE'
  | 'GREATER_EQUAL'
  | 'GREATER'
  | 'LESS_EQUAL'
  | 'LESS'

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
  | 'REPEAT_UNTIL_GAME_OVER'
  | 'RETURN'
  | 'SET'
  | 'TO'
  | 'TRUE'
  | 'WHILE'
  | 'WITH'

  // Grouping tokens
  | 'STRICT_EQUALITY'
  | 'STRICT_INEQUALITY'

  // Invisible tokens
  | 'EOL' // End of statement
  | 'EOF' // End of file

export type Token = {
  type: TokenType
  lexeme: string
  literal: any
  location: Location
}
