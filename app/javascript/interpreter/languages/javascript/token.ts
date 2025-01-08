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
  | 'PLUS'
  | 'QUESTION_MARK'
  | 'RIGHT_BRACE'
  | 'RIGHT_BRACKET'
  | 'RIGHT_PAREN'
  | 'SLASH'
  | 'STAR'

  // One, two or three character tokens.
  | 'AMPERSAND_AMPERSAND'
  | 'NOT'
  | 'DOLLAR_LEFT_BRACE'
  | 'EQUAL'
  | 'GREATER_EQUAL'
  | 'GREATER'
  | 'LESS_EQUAL'
  | 'LESS'
  | 'MINUS_EQUAL'
  | 'MINUS_MINUS'
  | 'PIPE_PIPE'
  | 'PLUS_PLUS'
  | 'PLUS_EQUAL'
  | 'SLASH_EQUAL'
  | 'STAR_EQUAL'

  // Literals
  | 'IDENTIFIER'
  | 'NUMBER'
  | 'STRING'
  | 'TEMPLATE_LITERAL_TEXT'

  // Keywords
  | 'AND'
  | 'CONST'
  | 'DO'
  | 'ELSE'
  | 'FALSE'
  | 'FOR'
  | 'FUNCTION'
  | 'IF'
  | 'IN'
  | 'LET'
  | 'NULL'
  | 'OF'
  | 'OR'
  | 'RETURN'
  | 'REPEAT_UNTIL_GAME_OVER'
  | 'TRUE'
  | 'WHILE'

  // Grouping tokens
  | 'EQUALITY'
  | 'STRICT_EQUALITY'
  | 'INEQUALITY'
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
