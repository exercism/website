import { Location } from './location'

export const KeywordTokens = ['VAR']

// Convert the array of strings into a union type
export type KeywordTokenType = (typeof KeywordTokens)[number]

export type TokenType =
  | KeywordTokenType

  // Single-character tokens
  | 'DOT'
  | 'HASH'
  | 'LEFT_BRACE'
  | 'RIGHT_BRACE'
  | 'COLON'
  | 'COMMA'
  | 'DOUBLE_QUOTE'
  | 'SEMICOLON'
  | 'LEFT_PAREN'
  | 'RIGHT_PAREN'

  // Literals
  | 'IDENTIFIER'
  | 'STRING'
  | 'NUMBER'
  | 'VALUE'

  // Invisible tokens
  | 'EOL' // End of statement
  | 'EOF' // End of file

export type Token = {
  type: TokenType
  lexeme: string
  literal: any
  location: Location
}
