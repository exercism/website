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
import {
  DisabledLanguageFeatureError,
  type DisabledLanguageFeatureErrorType,
  SyntaxError,
  SyntaxErrorType,
} from './error'
import type { Token, TokenType } from './token'
import { Location } from './location'
import type { LanguageFeatures } from './interpreter'
import { translate } from './translator'

export class Scanner {
  private tokens: Token[] = []
  private start: number = 0
  private current: number = 0
  private line: number = 1
  private lineOffset: number = 0
  private sourceCode: string = ''

  private static readonly keywords: Record<string, TokenType> = {
    and: 'AND',
    break: 'BREAK',
    by: 'BY',
    change: 'CHANGE',
    class: 'CLASS',
    constructor: 'CONSTRUCTOR',
    continue: 'CONTINUE',
    do: 'DO',
    else: 'ELSE',
    end: 'END',
    false: 'FALSE',
    for: 'FOR',
    each: 'EACH',
    function: 'FUNCTION',
    if: 'IF',
    in: 'IN',
    indexed: 'INDEXED',
    is: 'EQUALITY',
    log: 'LOG',
    method: 'METHOD',
    next: 'NEXT',
    new: 'NEW',
    null: 'NULL',
    not: 'NOT',
    or: 'OR',
    public: 'PUBLIC',
    private: 'PRIVATE',
    property: 'PROPERTY',
    repeat: 'REPEAT',
    repeat_forever: 'REPEAT_FOREVER',
    repeat_until_game_over: 'REPEAT_UNTIL_GAME_OVER',
    return: 'RETURN',
    set: 'SET',
    to: 'TO',
    true: 'TRUE',
    times: 'TIMES',
    this: 'THIS',
    // while: 'WHILE',
    with: 'WITH',
  }

  private readonly tokenizers: Record<string, Function> = {
    '(': this.tokenizeLeftParanthesis,
    ')': this.tokenizeRightParanthesis,
    '{': this.tokenizeLeftBrace,
    '}': this.tokenizeRightBrace,
    '[': this.tokenizeLeftBracket,
    ']': this.tokenizeRightBracket,
    ':': this.tokenizeColon,
    ',': this.tokenizeComma,
    '.': this.tokenizeDot,
    '+': this.tokenizePlus,
    '-': this.tokenizeMinus,
    '*': this.tokenizeStar,
    '/': this.tokenizeSlash,
    '%': this.tokenizePercent,
    '>': this.tokenizeGreater,
    '<': this.tokenizeLess,
    '!': this.tokenizeBang,
    '=': this.tokenizeEqual,
    ' ': this.tokenizeWhitespace,
    '\t': this.tokenizeWhitespace,
    '\r': this.tokenizeWhitespace,
    '\n': this.tokenizeNewline,
    '"': this.tokenizeString,
    '`': this.tokenizeTemplateLiteral,
  }

  constructor(private languageFeatures: LanguageFeatures = {}) {}

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
      } else if (this.isAlpha(c)) {
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
  private tokenizeBang() {
    this.addToken(this.match('=') ? 'INEQUALITY' : 'NOT')
  }

  private tokenizeEqual() {
    this.addToken(this.match('=') ? 'EQUALITY' : 'EQUAL')
  }
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
  private tokenizeLeftBracket() {
    this.addToken('LEFT_BRACKET')
  }
  private tokenizeRightBracket() {
    this.addToken('RIGHT_BRACKET')
  }
  private tokenizeColon() {
    this.addToken('COLON')
  }
  private tokenizeComma() {
    this.addToken('COMMA')
  }
  private tokenizeDot() {
    this.addToken('DOT')
  }
  private tokenizePlus() {
    this.addToken('PLUS')
  }
  private tokenizeMinus() {
    this.addToken('MINUS')
  }
  private tokenizeStar() {
    this.addToken('STAR')
  }
  private tokenizeSlash() {
    if (this.peek() == '/') {
      this.tokenizeComment()
    } else {
      this.addToken('SLASH')
    }
  }
  private tokenizePercent() {
    this.addToken('PERCENT')
  }
  private tokenizeGreater() {
    this.addToken(this.match('=') ? 'GREATER_EQUAL' : 'GREATER')
  }
  private tokenizeLess() {
    this.addToken(this.match('=') ? 'LESS_EQUAL' : 'LESS')
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

  // TODO: Check whether this errors correctly if split over lines
  private tokenizeTemplateLiteral(): void {
    this.addToken('BACKTICK')

    while (this.peek() != '`' && this.isAnotherCharacter()) {
      this.start = this.current

      if (this.peek() != '$' && this.peekNext() != '{' && !this.isAtEnd()) {
        while (
          this.peek() != '$' &&
          this.peek() != '`' &&
          this.peekNext() != '{' &&
          !this.isAtEnd()
        )
          this.advance()

        this.addToken(
          'TEMPLATE_LITERAL_TEXT',
          this.sourceCode.substring(this.start, this.current)
        )
      } else {
        this.advance() // Consume the $
        this.advance() // Consume the {
        this.addToken('DOLLAR_LEFT_BRACE')
        this.start = this.current

        while (this.peek() != '}' && !this.isAtEnd()) {
          this.start = this.current
          this.scanToken()
        }

        if (this.isAtEnd())
          this.error('MissingRightBraceToTerminatePlaceholder')

        this.start = this.current
        this.advance()
        this.addToken('RIGHT_BRACE') // Consume the }
      }
    }

    if (this.isAtEnd()) this.error('MissingBacktickToTerminateTemplateLiteral')

    this.start = this.current
    this.advance()
    this.addToken('BACKTICK') // Consume the closing `
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
    if (lexeme == 'is') {
      return 'EQUALITY'
    }
    if (lexeme == 'equals') {
      return 'EQUALITY'
    }

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
    this.verifyEnabled(type, this.lexeme())

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
    return this.isAlpha(c) || this.isDigit(c) || c == '#'
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

  private peekNext(): string {
    if (this.current + 1 >= this.sourceCode.length) return '\0'
    return this.sourceCode[this.current + 1]
  }

  private previouslyAddedToken(): TokenType | null {
    if (this.tokens.length === 0) return null
    return this.tokens[this.tokens.length - 1].type
  }

  private match(expected: string): boolean {
    if (this.isAtEnd()) return false
    if (this.sourceCode[this.current] != expected) return false

    this.current++
    return true
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

  private verifyEnabled(tokenType: TokenType, lexeme: string): void {
    if (!this.languageFeatures) return

    if (
      this.languageFeatures.excludeList &&
      this.languageFeatures.excludeList.includes(tokenType)
    )
      this.disabledLanguageFeatureError('ExcludeListViolation', {
        excludeList: this.languageFeatures.excludeList,
        tokenType,
        lexeme,
      })

    if (
      this.languageFeatures.includeList &&
      !this.languageFeatures.includeList.includes(tokenType)
    )
      this.disabledLanguageFeatureError('IncludeListViolation', {
        includeList: this.languageFeatures.includeList,
        tokenType,
        lexeme,
      })
  }

  private error(type: SyntaxErrorType, context: any = {}): never {
    throw new SyntaxError(
      translate(`error.syntax.${type}`, context),
      this.location(),
      type,
      context
    )
  }

  private disabledLanguageFeatureError(
    type: DisabledLanguageFeatureErrorType,
    context: any
  ): never {
    throw new DisabledLanguageFeatureError(
      translate(`error.disabledLanguageFeature.${type}`, context),
      this.location(),
      type,
      context
    )
  }
}

export function scan(
  sourceCode: string,
  ...args: [LanguageFeatures?]
): Token[] {
  return new Scanner(...args).scanTokens(sourceCode)
}
