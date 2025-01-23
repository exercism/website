import { SyntaxError } from './error'
import { type SyntaxErrorType } from './error'
import {
  ArrayExpression,
  BinaryExpression,
  CallExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  DictionaryExpression,
  UnaryExpression,
  VariableExpression,
  GetExpression,
  SetExpression,
  TemplateLiteralExpression,
  TemplatePlaceholderExpression,
  TemplateTextExpression,
} from './expression'
import type { LanguageFeatures } from './interpreter'
import { Location } from './location'
import { Scanner } from './scanner'
import {
  BlockStatement,
  ExpressionStatement,
  ForeachStatement,
  FunctionParameter,
  FunctionStatement,
  IfStatement,
  RepeatStatement,
  RepeatUntilGameOverStatement,
  ReturnStatement,
  Statement,
  SetVariableStatement,
  WhileStatement,
  ChangeVariableStatement,
} from './statement'
import type { Token, TokenType } from './token'
import { translate } from './translator'
import { isTypo } from './helpers/isTypo'
import { errorForMissingDoAfterParameters } from './helpers/complexErrors'

export class Parser {
  private readonly scanner: Scanner
  private current: number = 0
  private tokens: Token[] = []

  constructor(
    private functionNames: string[] = [],
    languageFeatures: LanguageFeatures,
    private shouldWrapTopLevelStatements: boolean
  ) {
    this.scanner = new Scanner(languageFeatures)
  }

  public parse(sourceCode: string): Statement[] {
    this.tokens = this.scanner.scanTokens(sourceCode)

    const statements = []

    while (!this.isAtEnd()) {
      const statement = this.declarationStatement()
      if (statement) {
        statements.push(statement)
      }
    }

    if (this.shouldWrapTopLevelStatements)
      return this.wrapTopLevelStatements(statements)

    return statements
  }

  wrapTopLevelStatements(statements: Statement[]): Statement[] {
    const functionStmt = new FunctionStatement(
      {
        type: 'IDENTIFIER',
        lexeme: 'main',
        literal: null,
        location: Location.unknown,
      },
      [],
      [],
      Location.unknown
    )

    for (let i = statements.length - 1; i >= 0; i--) {
      // Don't wrap top-level function statements
      if (statements[i] instanceof FunctionStatement) continue

      functionStmt.body.unshift(statements[i])
      statements.splice(i, 1)
    }

    statements.push(functionStmt)
    return statements
  }

  private declarationStatement(): Statement {
    if (this.match('FUNCTION')) return this.functionStatement()

    return this.statement()
  }

  private functionStatement(): Statement {
    const name = this.consume('IDENTIFIER', 'MissingFunctionName')
    const parameters: FunctionParameter[] = []
    if (this.match('WITH')) {
      do {
        if (parameters.length > 255) {
          this.error(
            'ExceededMaximumNumberOfParameters',
            this.peek().location,
            {
              maximum: 255,
              actual: parameters.length,
              name,
            }
          )
        }

        const parameterName = this.consume(
          'IDENTIFIER',
          'MissingParameterName',
          {
            name: name,
          }
        )

        if (parameters.find((p) => p.name.lexeme == parameterName.lexeme)) {
          this.error('DuplicateParameterName', this.previous().location, {
            parameter: parameterName.lexeme,
          })
        }

        parameters.push(new FunctionParameter(parameterName, null))
      } while (this.match('COMMA'))
    }
    if (this.peek().type != 'DO') {
      const { errorType, context } = errorForMissingDoAfterParameters(
        this.peek(),
        parameters
      )
      this.error(errorType, this.peek().location, context)
    }
    this.consume('DO', 'MissingDoToStartBlock', { type: 'function', name })
    this.consumeEndOfLine()

    const body = this.block('function')
    this.functionNames.push(name.lexeme)
    return new FunctionStatement(
      name,
      parameters,
      body,
      Location.between(name, this.previous())
    )
  }

  private statement(): Statement {
    if (this.match('SET')) return this.setVariableStatement()
    if (this.match('CHANGE')) return this.changeVariableStatement()
    if (this.match('IF')) return this.ifStatement()
    if (this.match('RETURN')) return this.returnStatement()
    if (this.match('REPEAT')) return this.repeatStatement()
    if (this.match('REPEAT_UNTIL_GAME_OVER'))
      return this.repeatUntilGameOverStatement()
    if (this.match('WHILE')) return this.whileStatement()
    if (this.match('FOREACH')) return this.foreachStatement()
    if (this.match('DO')) return this.blockStatement('do')

    // Error cases
    if (this.match('ELSE')) {
      this.error('UnexpectedElseWithoutIf', this.previous().location)
    }

    return this.expressionStatement()
  }

  private setupVariableStatement(): Statement {
    const setToken = this.previous()

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

    if (
      (this.peek().type == 'IDENTIFIER' || this.peek().type == 'STRING') &&
      this.peek(2).type == 'TO'
    ) {
      const errorLocation = Location.between(this.previous(), this.peek())
      this.error('UnexpectedSpaceInIdentifier', errorLocation, {
        first_half: name.lexeme,
        second_half: this.peek().lexeme,
      })
    }

    // Guard mistaken equals sign for assignment
    this.guardEqualsSignForAssignment(this.peek())

    this.consume('TO', 'MissingToAfterVariableNameToInitializeValue', {
      name: name.lexeme,
    })

    const initializer = this.expression()
    this.consumeEndOfLine()

    return [name, initializer, setToken]
  }

  private setVariableStatement(): Statement {
    const [name, initializer, setToken] = this.setupVariableStatement()
    return new SetVariableStatement(
      name,
      initializer,
      Location.between(setToken, initializer)
    )
  }

  private changeVariableStatement(): Statement {
    const [name, initializer, changeToken] = this.setupVariableStatement()
    return new ChangeVariableStatement(
      name,
      initializer,
      Location.between(changeToken, initializer)
    )
  }

  private ifStatement(): Statement {
    const ifToken = this.previous()
    let condition
    try {
      condition = this.expression()
      if (condition instanceof LiteralExpression) {
        this.error('UnexpectedLiteralExpressionAfterIf', ifToken.location)
      }
      if (condition instanceof VariableExpression) {
        const typoData = isTypo(this.peek())
        if (typoData) {
          this.error(
            'UnexpectedVariableExpressionAfterIfWithPotentialTypo',
            ifToken.location,
            { actual: typoData.actual, potential: typoData.potential }
          )
        }

        this.error('UnexpectedVariableExpressionAfterIf', ifToken.location)
      }
    } catch (e) {
      if (e instanceof SyntaxError && e.type == 'MissingExpression') {
        this.error('MissingConditionAfterIf', ifToken.location)
      } else {
        throw e
      }
    }

    this.consume('DO', 'MissingDoToStartBlock', { type: 'if' })
    const thenBranch = this.blockStatement('if', {
      allowElse: true,
      consumeEnd: false,
    })
    let elseBranch: Statement | null = null

    if (this.match('ELSE')) {
      if (this.match('IF')) {
        elseBranch = this.ifStatement()
      } else {
        this.consume('DO', 'MissingDoToStartBlock', { type: 'else' })
        elseBranch = this.blockStatement('else')
      }
    } else {
      this.consume('END', 'MissingEndAfterBlock', { type: 'if' })
      this.consumeEndOfLine()
    }

    // console.log(condition, thenBranch, elseBranch, ifToken, this.previous());

    return new IfStatement(
      condition,
      thenBranch,
      elseBranch,
      Location.between(ifToken, this.previous())
    )
  }

  private returnStatement(): Statement {
    const keyword = this.previous()
    const value: Expression | null = this.isAtEndOfStatement()
      ? null
      : this.expression()

    this.consumeEndOfLine()

    return new ReturnStatement(
      keyword,
      value,
      Location.between(keyword, value || keyword)
    )
  }

  private repeatStatement(): Statement {
    const begin = this.previous()
    const condition = this.expression()
    this.consume('TIMES', 'MissingTimesInRepeat')
    this.consume('DO', 'MissingDoToStartBlock', { type: 'repeat' })
    this.consumeEndOfLine()

    const statements = this.block('repeat')

    return new RepeatStatement(
      condition,
      statements,
      Location.between(begin, this.previous())
    )
  }

  private repeatUntilGameOverStatement(): Statement {
    const begin = this.previous()

    this.consume('DO', 'MissingDoToStartBlock', {
      type: 'repeat_until_game_over',
    })
    this.consumeEndOfLine()

    const statements = this.block('repeat_until_game_over')

    return new RepeatUntilGameOverStatement(
      statements,
      Location.between(begin, this.previous())
    )
  }

  private whileStatement(): Statement {
    const begin = this.previous()
    const condition = this.expression()

    this.consume('DO', 'MissingDoToStartBlock', { type: 'while' })
    this.consumeEndOfLine()

    const statements = this.block('while')

    return new WhileStatement(
      condition,
      statements,
      Location.between(begin, this.previous())
    )
  }

  private foreachStatement(): Statement {
    const foreachToken = this.previous()
    const elementName = this.consume(
      'IDENTIFIER',
      'MissingElementNameAfterForeach'
    )
    this.consume('IN', 'MissingOfAfterElementNameInForeach', {
      elementName,
    })
    const iterable = this.expression()

    this.consume('DO', 'MissingDoToStartBlock', { type: 'foreach' })
    this.consumeEndOfLine()

    const statements = this.block('foreach')

    return new ForeachStatement(
      elementName,
      iterable,
      statements,
      Location.between(foreachToken, this.previous())
    )
  }

  private blockStatement(
    type: string,
    { allowElse, consumeEnd } = { allowElse: false, consumeEnd: true }
  ): BlockStatement {
    const doToken = this.previous()
    this.consumeEndOfLine()
    const statements = this.block(type, { allowElse, consumeEnd })

    return new BlockStatement(
      statements,
      Location.between(doToken, this.previous())
    )
  }

  private block(
    type: string,
    { allowElse, consumeEnd } = { allowElse: false, consumeEnd: true }
  ): Statement[] {
    const statements: Statement[] = []

    while (
      !this.check('END') &&
      (!allowElse || !this.check('ELSE')) &&
      !this.isAtEnd()
    ) {
      statements.push(this.statement())
    }

    if (consumeEnd && (!allowElse || this.peek().type != 'ELSE')) {
      this.consume('END', 'MissingEndAfterBlock', { type })
      this.consumeEndOfLine()
    }
    return statements
  }

  private expressionStatement(): Statement {
    const expression = this.expression()
    this.consumeEndOfLine()

    return new ExpressionStatement(expression, expression.location)
  }

  private expression(): Expression {
    return this.assignment()
  }

  private assignment(): Expression {
    const expr = this.or()

    if (this.match('TO')) {
      const operator = this.previous()
      const value = this.assignment()

      if (expr instanceof VariableExpression) {
        return new ChangeVariableStatement(
          expr.name,
          operator,
          value,
          true,
          Location.between(expr, value)
        )
      }

      if (expr instanceof GetExpression) {
        return new SetExpression(
          expr.obj,
          expr.field,
          value,
          Location.between(expr, value)
        )
      }

      this.error('InvalidAssignmentTarget', expr.location, {
        assignmentTarget: expr,
      })
    }

    return expr
  }

  private or(): Expression {
    const expr = this.and()

    while (this.match('OR')) {
      let operator = this.previous()
      operator.type = 'OR'
      const right = this.and()
      return new LogicalExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private and(): Expression {
    const expr = this.equality()

    while (this.match('AND')) {
      let operator = this.previous()
      operator.type = 'AND'
      const right = this.equality()
      return new LogicalExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private equality(): Expression {
    let expr = this.comparison()

    while (this.match('EQUALITY')) {
      let operator = this.previous()
      const right = this.comparison()
      expr = new BinaryExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    this.guardEqualsSignForEquality(this.peek())

    return expr
  }

  private comparison(): Expression {
    let expr = this.term()

    while (
      this.match(
        'GREATER',
        'GREATER_EQUAL',
        'LESS',
        'LESS_EQUAL',
        'EQUALITY',
        'INEQUALITY'
      )
    ) {
      const operator = this.previous()
      const right = this.term()
      expr = new BinaryExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private term(): Expression {
    let expr = this.factor()

    while (this.match('MINUS', 'PLUS')) {
      const operator = this.previous()
      const right = this.factor()
      expr = new BinaryExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private factor(): Expression {
    let expr = this.unary()

    while (this.match('SLASH', 'STAR', 'PERCENT')) {
      const operator = this.previous()
      const right = this.unary()
      expr = new BinaryExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private unary(): Expression {
    if (this.match('NOT', 'MINUS')) {
      const operator = this.previous()
      const right = this.unary()
      return new UnaryExpression(
        operator,
        right,
        Location.between(operator, right)
      )
    }

    return this.call()
  }

  private call(): Expression {
    let expression = this.primary()

    while (true) {
      if (this.match('LEFT_PAREN')) {
        expression = this.finishCall(expression)
      } else if (this.match('LEFT_BRACKET')) {
        const leftBracket = this.previous()
        if (!this.match('STRING', 'NUMBER'))
          this.error(
            'MissingFieldNameOrIndexAfterLeftBracket',
            leftBracket.location,
            {
              expression,
            }
          )

        const name = this.previous()
        const rightBracket = this.consume(
          'RIGHT_BRACKET',
          'MissingRightBracketAfterFieldNameOrIndex',
          { expression, name }
        )
        expression = new GetExpression(
          expression,
          name,
          Location.between(expression, rightBracket)
        )
      } else {
        if (
          expression instanceof VariableExpression &&
          this.functionNames.includes(expression.name.lexeme) &&
          this.match('RIGHT_PAREN')
        )
          this.error(
            'MissingLeftParenthesisAfterFunctionCall',
            this.previous().location,
            { expression, function: expression.name.lexeme }
          )
        break
      }
    }

    return expression
  }

  private finishCall(callee: Expression): Expression {
    const args: Expression[] = []

    if (this.match('EOL')) {
      this.error('MissingRightParenthesisAfterFunctionCall', callee.location, {
        function:
          callee instanceof VariableExpression ? callee.name.lexeme : null,
      })
    }
    if (!this.check('RIGHT_PAREN')) {
      do {
        args.push(this.expression())
      } while (this.match('COMMA'))
    }

    const paren = this.consume(
      'RIGHT_PAREN',
      'MissingRightParenthesisAfterFunctionCall',
      {
        args,
        function:
          callee instanceof VariableExpression ? callee.name.lexeme : null,
      }
    )
    return new CallExpression(
      callee,
      paren,
      args,
      Location.between(callee, paren)
    )
  }

  private primary(): Expression {
    if (this.match('LEFT_BRACKET')) return this.array()

    if (this.match('LEFT_BRACE')) return this.dictionary()

    if (this.match('FALSE'))
      return new LiteralExpression(false, this.previous().location)

    if (this.match('TRUE'))
      return new LiteralExpression(true, this.previous().location)

    if (this.match('NULL'))
      return new LiteralExpression(null, this.previous().location)

    if (this.match('NUMBER', 'STRING'))
      return new LiteralExpression(
        this.previous().literal,
        this.previous().location
      )

    if (this.match('IDENTIFIER'))
      return new VariableExpression(this.previous(), this.previous().location)

    if (this.match('BACKTICK')) return this.templateLiteral()

    if (this.match('LEFT_PAREN')) {
      const lparen = this.previous()
      const expression = this.expression()

      // TODO: If there's not a right paren here,

      let rparen
      try {
        rparen = this.consume(
          'RIGHT_PAREN',
          'MissingRightParenthesisAfterExpression',
          {
            expression,
          }
        )
      } catch (e) {
        // TODO: If there's not a right paren here, we could consider what's
        // happened instead. Maybe the person made a typo on the next character
        // For example, did they put "equal" instead of "equals"?
        const typoData = isTypo(this.peek())
        if (typoData) {
          this.error(
            'MissingRightParenthesisAfterExpressionWithPotentialTypo',
            typoData.location,
            { actual: typoData.actual, potential: typoData.potential }
          )
        }

        throw e
      }

      return new GroupingExpression(
        expression,
        Location.between(lparen, rparen)
      )
    }

    this.error('MissingExpression', this.peek().location)
  }

  private templateLiteral(): Expression {
    const openBacktick = this.previous()
    const parts: Expression[] = []

    while (this.peek().type != 'BACKTICK') {
      if (this.match('DOLLAR_LEFT_BRACE')) {
        const dollarLeftBrace = this.previous()
        const expr = this.expression()
        const rightBrace = this.consume(
          'RIGHT_BRACE',
          'MissingRightBraceToTerminatePlaceholder',
          { expr }
        )
        parts.push(
          new TemplatePlaceholderExpression(
            expr,
            Location.between(dollarLeftBrace, rightBrace)
          )
        )
      } else {
        const textToken = this.consume(
          'TEMPLATE_LITERAL_TEXT',
          'InvalidTemplateLiteral'
        )
        parts.push(new TemplateTextExpression(textToken, textToken.location))
      }
    }

    const closeBacktick = this.consume(
      'BACKTICK',
      'MissingBacktickToTerminateTemplateLiteral',
      { elements: parts }
    )
    return new TemplateLiteralExpression(
      parts,
      Location.between(openBacktick, closeBacktick)
    )
  }

  private array(): Expression {
    const leftBracket = this.previous()
    const elements: Expression[] = []

    if (!this.check('RIGHT_BRACKET')) {
      do {
        elements.push(this.or())
      } while (this.match('COMMA'))
    }

    const rightBracket = this.consume(
      'RIGHT_BRACKET',
      'MissingRightBracketAfterListElements',
      { elements }
    )
    return new ArrayExpression(
      elements,
      Location.between(leftBracket, rightBracket)
    )
  }

  private dictionary(): Expression {
    const leftBrace = this.previous()
    const elements = new Map<string, Expression>()

    if (!this.check('RIGHT_BRACE')) {
      do {
        const key = this.consume('STRING', 'MissingStringAsKey')
        this.consume('COLON', 'MissingColonAfterKey')
        elements.set(key.literal, this.primary())
      } while (this.match('COMMA'))
    }

    const rightBracket = this.consume(
      'RIGHT_BRACE',
      'MissingRightBraceAfterMapElements',
      { elements }
    )
    return new DictionaryExpression(
      elements,
      Location.between(leftBrace, rightBracket)
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

  private check(tokenType: TokenType): boolean {
    if (this.isAtEnd()) return false
    return this.peek().type == tokenType
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

  private consumeEndOfLine(): void {
    if (this.match('EOL')) {
      return
    }

    // We're now at an error point where the next character
    // should be an EOL but isn't. We provide contextual guidance

    const type = this.peek().type
    const previous = this.previous().lexeme
    const current = this.peek().lexeme
    let suggestion

    if (type == 'FUNCTION') {
      suggestion = 'Did you mean to start a function on a new line?'
    } else {
      suggestion = 'Did you make a typo?'
    }
    this.error('MissingEndOfLine', this.peek().location, {
      previous,
      current,
      suggestion,
    })
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

  private guardEqualsSignForAssignment(name: Token) {
    if (this.peek().type == 'EQUAL') {
      this.error('UnexpectedEqualsForAssignment', this.peek().location, {
        name: name.lexeme,
      })
    }
  }
  private guardEqualsSignForEquality(token: Token) {
    if (token.type == 'EQUAL') {
      this.error('UnexpectedEqualsForEquality', token.location)
    }
  }

  private isAtEnd(): boolean {
    return this.peek().type == 'EOF'
  }

  private isAtEndOfStatement(): boolean {
    return this.peek().type == 'EOL' || this.isAtEnd()
  }

  private peek(n = 1): Token {
    return this.tokens[this.current + (n - 1)]
  }

  private previous(n = 1): Token {
    return this.tokens[this.current - n]
  }
}
export function parse(
  sourceCode: string,
  {
    functionNames = [],
    languageFeatures = {},
    shouldWrapTopLevelStatements = false,
  }: {
    functionNames?: string[]
    languageFeatures?: LanguageFeatures
    shouldWrapTopLevelStatements?: boolean
  } = {}
): Statement[] {
  return new Parser(
    functionNames,
    languageFeatures,
    shouldWrapTopLevelStatements
  ).parse(sourceCode)
}
