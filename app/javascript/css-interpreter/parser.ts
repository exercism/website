import { t } from 'xstate'
import { SyntaxError } from './error'
import { type SyntaxErrorType } from './error'
import { ValueExpression } from './expression'
import { Location } from './location'
import { Scanner } from './scanner'
import { Statement, SelectorStatement, PropertyStatement } from './statement'
import { KeywordTokens, type Token, type TokenType } from './token'
import { translate } from './translator'

export class Parser {
  private readonly scanner: Scanner
  private current: number = 0
  private tokens: Token[] = []

  constructor() {
    this.scanner = new Scanner()
  }

  public parse(sourceCode: string): Statement[] {
    this.tokens = this.scanner.scanTokens(sourceCode)

    const statements: Statement[] = []

    while (!this.isAtEnd()) {
      const statement = this.statement()
      if (statement) {
        statements.push(statement)
      }
      while (this.match('EOL')) {}
    }

    return statements
  }

  private statement(): Statement {
    const type: 'selector' | 'property' | null = null
    let peekDistance = 1
    while (!this.isAtEnd()) {
      const tokenType = this.peek(peekDistance).type
      console.log(tokenType)
      if (tokenType == 'LEFT_BRACE') {
        return this.selectorStatement()
      }
      if (tokenType == 'COLON') {
        return this.propertyStatement()
      }
      peekDistance++
    }
    console.log(this.peek())
    this.error('UknownStatementType', this.peek().location)
  }

  private selectorStatement(): SelectorStatement {
    const selectors: Token[] = []
    while (!this.match('LEFT_BRACE') && !this.isAtEnd()) {
      const identifier = this.consume('IDENTIFIER', 'MissingSelector')
      selectors.push(identifier)

      if (this.check('COMMA')) {
        this.consume('COMMA', 'MissingCommaAfterSelector')
        this.match('EOL')
        continue
      }
      if (this.check('LEFT_BRACE')) {
        break
      }

      this.error('MissingCommaAfterSelector', this.peek().location)
    }
    this.consume('LEFT_BRACE', 'MissingOpeningBrace')

    const body: Statement[] = []
    while (!this.check('RIGHT_BRACE') && !this.isAtEnd()) {
      body.push(this.statement())
    }
    this.consume('RIGHT_BRACE', 'MissingClosingBrace')

    return new SelectorStatement(
      selectors,
      body,
      Location.between(selectors[0], selectors[selectors.length - 1])
    )
  }

  private propertyStatement(): PropertyStatement {
    const property = this.consume('IDENTIFIER', 'MissingProperty')
    this.consume('COLON', 'MissingColonAfterProperty')
    const value = this.expression()
    return new PropertyStatement(
      property,
      value,
      Location.between(property, value)
    )
  }

  private identifier(): Token {
    let name
    try {
      name = this.consume('IDENTIFIER', 'MissingVariableName')
    } catch (e) {
      const nameLexeme = this.peek().lexeme
      if (nameLexeme.match(/[0-9]/)) {
        this.error('InvalidNumericVariableName', this.peek().location, {
          name: nameLexeme,
        })
      } else {
        throw e
      }
    }

    if (this.peek().type == 'IDENTIFIER' && this.peek(2).type == 'TO') {
      const errorLocation = Location.between(this.previous(), this.peek())
      this.error('UnexpectedSpaceInIdentifier', errorLocation, {
        first_half: name.lexeme,
        second_half: this.peek().lexeme,
      })
    }
    return name
  }
  private expression(): ValueExpression {
    const tokens: Token[] = []
    while (!(this.peek().type == 'SEMICOLON') && !this.isAtEnd()) {
      tokens.push(this.advance())
    }
    const value = tokens.map((t) => t.lexeme).join('')
    return new ValueExpression(
      value,
      Location.between(tokens[0], tokens[tokens.length - 1])
    )
  }

  private match(...tokenTypes: TokenType[]): boolean {
    for (const tokenType of tokenTypes) {
      if (this.check(tokenType)) {
        this.advance()
        return true
      }
    }
    return false
  }

  private check(...tokenTypes: TokenType[]): boolean {
    if (this.isAtEnd()) return false
    return tokenTypes.includes(this.peek().type)
  }

  private checkAhead(steps = 1, ...tokenTypes: TokenType[]): boolean {
    if (this.isAtEnd()) return false
    return tokenTypes.includes(this.peek(steps).type)
  }

  private advance(): Token {
    if (!this.isAtEnd()) this.current++
    return this.previous()
  }

  private consume(
    tokenType: TokenType,
    type: SyntaxErrorType,
    context?: any
  ): Token {
    if (this.check(tokenType)) return this.advance()

    this.error(type, this.peek().location, context)
  }

  private consumeDo(type): void {
    const next = this.peek()

    // The DO will work, the EOL will fail.
    // Both of these can be handled normally.
    if (next.type == 'EOL' || next.type == 'DO') {
      this.consume('DO', 'MissingDoToStartBlock', { type })
      return
    }

    if ([')', '}', ']'].includes(next.lexeme)) {
      this.error('UnexpectedClosingBracket', this.peek().location, {
        lexeme: next.lexeme,
      })
    } else {
      this.error('UnexpectedToken', this.peek().location, {
        lexeme: next.lexeme,
      })
    }
  }

  private error(
    type: SyntaxErrorType,
    location: Location,
    context?: any
  ): never {
    throw new SyntaxError(
      translate(`error.syntax.${type}`, context),
      location,
      type,
      context
    )
  }

  private isAtEnd(): boolean {
    return this.peek().type == 'EOF'
  }

  private peek(n = 1): Token {
    return this.tokens[this.current + (n - 1)]
  }

  private previous(n = 1): Token {
    return this.tokens[this.current - n]
  }
}
export function parse(sourceCode: string): Statement[] {
  return new Parser().parse(sourceCode)
}
