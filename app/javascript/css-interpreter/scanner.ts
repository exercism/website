/*
 * The scanner is the first part of the interpreter.
 * It takes the source code as input and produces a list of tokens, that
 * represent the different conceptual elements of the source code. For example,
 * it takes a whole string and reduces it into a STRING token, and it takes an
 * equals sign and turns it into an EQUAL token.
 *
 * These tokens will then be used by the parser to build a tree of expressions,
 * which will be used by the interpreter to execute the program.
 *
 * The main workflow here is looking at the next character in the source code,
 * and then deciding what to do with it. Sometimes we just immediate "consume" it
 * (turn it into a token), but other times we need to peak ahead and see what comes
 * next to know what token to produce or how to handle it.
 *
 * This process will also produce errors if the source code is invalid, for example
 * if we see an unterminated string, or a number with multiple decimal points.
 */
import { SyntaxError, SyntaxErrorType } from './error'
import type { Token, TokenType } from './token'
import { Location } from './location'
import { translate } from './translator'

export class Scanner {
  private tokens: Token[] = []
  private start: number = 0
  private current: number = 0
  private line: number = 1
  private lineOffset: number = 0
  private sourceCode: string = ''

  private static readonly keywords: Record<string, TokenType> = {
    var: 'VAR',
  }

  private readonly tokenizers: Record<string, Function> = {
    '{': this.tokenizeLeftBrace,
    '}': this.tokenizeRightBrace,
    '(': this.tokenizeLeftParanthesis,
    ')': this.tokenizeRightParanthesis,
    ':': this.tokenizeColon,
    ',': this.tokenizeComma,
    '"': this.tokenizeString,
    ';': this.tokenizeSemicolon,
    ' ': this.tokenizeWhitespace,
    '\t': this.tokenizeWhitespace,
    '\r': this.tokenizeWhitespace,
    '\n': this.tokenizeNewline,
  }

  scanTokens(sourceCode: string): Token[] {
    this.sourceCode = sourceCode
    this.reset()

    while (!this.isAtEnd()) {
      this.start = this.current
      this.scanToken()
    }

    // Add synthetic EOL token to simplify parsing
    if (this.shouldAddEOLToken()) this.addSyntheticToken('EOL', '\n')

    // Add synthetic EOF token to simplify parsing
    this.addSyntheticToken('EOF', '\0')

    return this.tokens
  }

  private scanToken(): void {
    const c = this.advance()

    const tokenizer = this.tokenizers[c]
    if (tokenizer) {
      tokenizer.bind(this)()
    } else {
      if (this.isDigit(c)) {
        this.tokenizeNumber()
      } else if (this.isAlpha(c) || '.#'.includes(c)) {
        this.tokenizeIdentifier()
      } else {
        this.error('UnknownCharacter', {
          character: c,
        })
      }
    }
  }

  /**
   * These are tokenizers. The purpose of a tokenizer is to consume characters from the source code
   * and produce a token. The token is then added to the list of tokens.
   *
   * For example, if we see a left paranthesis, we add a token of type "LEFT_PAREN" to the list of tokens.
   *
   * Some tokens are more complex. For example if we see an equals sign, we need to check if the next character
   * is also an equals sign. If it is, we add a token of type "EQUAL_EQUAL" to the list of tokens. If it is not,
   * we add a token of type "EQUAL" to the list of tokens.
   *
   * Some are even more complex. For example, if we see a double quote, we need to consume characters until we see
   * another double quote. We then add a token of type "STRING" to the list of tokens
   * with all the characters between the double quotes consumed.
   */

  /* This first set of tokenizers are simple. They consume a single character and add a token to the list of tokens,
   * or do simple checks for the next characters (e.g. "++")
   */
  private tokenizeLeftParanthesis() {
    this.addToken('LEFT_PAREN')
  }
  private tokenizeRightParanthesis() {
    this.addToken('RIGHT_PAREN')
  }
  private tokenizeLeftBrace() {
    this.addToken('LEFT_BRACE')
  }
  private tokenizeRightBrace() {
    this.addToken('RIGHT_BRACE')
  }
  private tokenizeColon() {
    this.addToken('COLON')
  }
  private tokenizeComma() {
    this.addToken('COMMA')
  }
  private tokenizeSemicolon() {
    this.addToken('SEMICOLON')
  }

  /*
   * We don't tokenize whitespace, but we do need to match on it
   */
  private tokenizeWhitespace() {
    return
  }

  /*
   * The new line tokenizer not only adds a token, but also increments the line number
   * and resets the line offset to the next character.
   */
  private tokenizeNewline() {
    if (this.shouldAddEOLToken()) this.addToken('EOL')

    this.line++
    this.lineOffset = this.current
  }

  private tokenizeComment(): void {
    // Consume until the end of the line
    while (this.isAnotherCharacter()) {
      this.advance()
    }
  }

  private tokenizeString(): void {
    // Keep consuming characters until we see another double quote
    // and then stop before we consume it.
    while (this.peek() != '"' && this.isAnotherCharacter()) this.advance()

    // If we reach the end of the line, we have an unterminated string
    if (this.peek() != '"')
      if (this.previouslyAddedToken() == 'IDENTIFIER')
        this.error('MissingDoubleQuoteToStartString', {
          string: this.tokens[this.tokens.length - 1].lexeme,
        })
      else
        this.error('MissingDoubleQuoteToTerminateString', {
          string: this.sourceCode.substring(this.start + 1, this.current),
        })

    // Consume the closing quotation mark
    this.advance()

    // Finally add the token, with its value set to the characters between the quotes
    this.addToken(
      'STRING',
      this.sourceCode.substring(this.start + 1, this.current - 1)
    )
  }

  /*
   * For numbers, we consume any digits and a single decimal point, if present.
   * We then add a token with the value of the number.
   */
  private tokenizeNumber(): void {
    while (this.isDigit(this.peek()) || this.peek() == '.') this.advance()
    const number = this.sourceCode.substring(this.start, this.current)

    // Guard against numbers starting with 0
    if (
      number.startsWith('0') &&
      number.length > 1 &&
      !number.startsWith('0.')
    ) {
      this.error('NumberStartsWithZero', {
        suggestion: parseFloat(number),
      })
    }

    // Guard against numbers with invalid characters (e.g. "123abc")
    if (this.peek().match('[a-zA-Z]')) {
      this.error('NumberContainsAlpha', {
        suggestion: parseFloat(number),
      })
    }
    // Guard against trailing decimal points (e.g. "1.")
    if (number.endsWith('.')) {
      this.error('NumberEndsWithDecimalPoint', {
        suggestion: parseInt(number),
      })
    }

    // Guard against numbers with multiple decimal points (e.g. "1.2.4")
    if (number.split('.').length > 2) {
      const parts = number.split('.')
      const suggestion = parts[0] + '.' + parts.slice(1).join('')
      this.error('NumberWithMultipleDecimalPoints', {
        suggestion: suggestion,
      })
    }

    this.addToken('NUMBER', Number.parseFloat(number))
  }

  private tokenForLexeme(lexeme: string): string | null {
    const keyword = Scanner.keywords[this.lexeme()]
    if (keyword) return keyword

    if (Scanner.keywords[this.lexeme().toLowerCase()]) {
      this.error('MiscapitalizedKeyword', {
        actual: this.lexeme(),
        expected: this.lexeme().toLowerCase(),
      })
    }
    return null
  }

  private tokenizeIdentifier(): void {
    while (this.isAllowableInIdentifier(this.peek())) this.advance()

    const keywordType = this.tokenForLexeme(this.lexeme())
    if (keywordType) return this.addToken(keywordType)

    this.addToken('IDENTIFIER')
  }

  private addSyntheticToken(type: TokenType, lexeme: string): void {
    this.tokens.push({
      type,
      lexeme: lexeme,
      literal: null,
      location: this.location(),
    })
  }

  private addToken(type: TokenType, literal: any = null): void {
    this.tokens.push({
      type,
      lexeme: this.lexeme(),
      literal,
      location: this.location(),
    })
  }

  private isAlpha(c: string): boolean {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  }

  private isDigit(c: string): boolean {
    return c >= '0' && c <= '9'
  }

  private isAllowableInIdentifier(c: string): boolean {
    console.log(c, '.#'.includes(c))
    return this.isAlpha(c) || this.isDigit(c) || '.#'.includes(c)
  }

  private isAtEnd(): boolean {
    return this.current >= this.sourceCode.length
  }

  private isAnotherCharacter(): boolean {
    const next = this.peek()
    if (next == '\n') return false
    if (next == '\0') return false
    return true
  }

  private shouldAddEOLToken(): boolean {
    return (
      this.previouslyAddedToken() != null &&
      this.previouslyAddedToken() != 'EOL'
    )
  }

  private advance(): string {
    return this.sourceCode[this.current++]
  }

  private peek(): string {
    if (this.isAtEnd()) return '\0'
    return this.sourceCode[this.current]
  }

  private previouslyAddedToken(): TokenType | null {
    if (this.tokens.length === 0) return null
    return this.tokens[this.tokens.length - 1].type
  }

  private lexeme(): string {
    return this.sourceCode.substring(this.start, this.current)
  }

  private location(): Location {
    return Location.fromLineOffset(
      this.start + 1,
      this.current + 1,
      this.line,
      this.lineOffset
    )
  }

  private reset() {
    this.tokens = []
    this.start = 0
    this.current = 0
    this.line = 1
    this.lineOffset = 0
  }

  private error(type: SyntaxErrorType, context: any = {}): never {
    throw new SyntaxError(
      translate(`error.syntax.${type}`, context),
      this.location(),
      type,
      context
    )
  }
}

export function scan(sourceCode: string): Token[] {
  return new Scanner().scanTokens(sourceCode)
}
