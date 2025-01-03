import { scan } from '@/interpreter/languages/javascript/scanner'
import type { TokenType } from '@/interpreter/languages/javascript/token'

describe('single-character', () => {
  test.each([
    ['{', 'LEFT_BRACE'],
    ['[', 'LEFT_BRACKET'],
    ['(', 'LEFT_PAREN'],
    ['}', 'RIGHT_BRACE'],
    [']', 'RIGHT_BRACKET'],
    [')', 'RIGHT_PAREN'],
    [':', 'COLON'],
    [',', 'COMMA'],
    ['-', 'MINUS'],
    ['+', 'PLUS'],
    ['*', 'STAR'],
    ['/', 'SLASH'],
    // ["?", "QUESTION_MARK"],
  ])("'%s' token", (source: string, expectedType: string) => {
    const tokens = scan(source)
    expect(tokens[0].type).toBe(expectedType as TokenType)
    expect(tokens[0].lexeme).toBe(source)
    expect(tokens[0].literal).toBeNull
  })
})
