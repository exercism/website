import { SyntaxError } from '../../error'
import { type SyntaxErrorType } from './error'
import {
  ArrayExpression,
  AssignExpression,
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
  UpdateExpression,
  TernaryExpression,
} from '../../expression'
import type { LanguageFeatures } from '../../interpreter'
import { Location } from '../../location'
import { Scanner } from './scanner'
import {
  BlockStatement,
  ConstantStatement,
  DoWhileStatement,
  ExpressionStatement,
  ForeachStatement,
  FunctionParameter,
  FunctionStatement,
  IfStatement,
  RepeatStatement,
  RepeatUntilGameOverStatement,
  ReturnStatement,
  Statement,
  VariableStatement,
  WhileStatement,
} from '../../statement'
import type { Token, TokenType } from './token'
import { translate } from '../../translator'

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

    while (!this.isAtEnd()) statements.push(this.declarationStatement())

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
    this.consume('LEFT_PAREN', 'MissingLeftParenthesisAfterFunctionName', {
      name,
    })
    const parameters: FunctionParameter[] = []
    if (!this.check('RIGHT_PAREN')) {
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

        let defaultValue: Expression | null = null

        if (this.match('EQUAL')) {
          defaultValue = this.expression()
        }

        parameters.push(new FunctionParameter(parameterName, defaultValue))
      } while (this.match('COMMA'))
    }
    this.consume('RIGHT_PAREN', 'MissingRightParenthesisAfterParameters', {
      name,
      parameters,
    })
    this.consume('LEFT_BRACE', 'MissingLeftBraceToStartFunctionBody', { name })
    this.consumeEndOfLine()

    const body = this.block()
    this.functionNames.push(name.lexeme)
    return new FunctionStatement(
      name,
      parameters,
      body,
      Location.between(name, this.previous())
    )
  }

  private statement(): Statement {
    if (this.match('LET')) return this.letStatement()
    if (this.match('CONST')) return this.constStatement()
    if (this.match('IF')) return this.ifStatement()
    if (this.match('RETURN')) return this.returnStatement()
    if (this.match('REPEAT_UNTIL_GAME_OVER'))
      return this.repeatUntilGameOverStatement()
    if (this.match('WHILE')) return this.whileStatement()
    if (this.match('DO')) return this.doWhileStatement()
    if (this.match('FOR')) return this.foreachStatement()
    if (this.match('LEFT_BRACE')) return this.blockStatement()

    return this.expressionStatement()
  }

  private letStatement(): Statement {
    const letToken = this.previous()
    const name = this.consume('IDENTIFIER', 'MissingVariableName')
    this.consume(
      'EQUAL',
      'MissingEqualsSignAfterVariableNameToInitializeValue',
      {
        name,
      }
    )

    const initializer = this.expression()
    this.consumeEndOfLine()

    return new VariableStatement(
      name,
      initializer,
      Location.between(letToken, initializer)
    )
  }

  private constStatement(): Statement {
    const constToken = this.previous()
    const name = this.consume('IDENTIFIER', 'MissingConstantName')
    this.consume(
      'EQUAL',
      'MissingEqualsSignAfterConstantNameToInitializeValue',
      {
        name,
      }
    )

    const initializer = this.expression()
    this.consumeEndOfLine()

    return new ConstantStatement(
      name,
      initializer,
      Location.between(constToken, initializer)
    )
  }

  private ifStatement(): Statement {
    const ifToken = this.previous()
    this.consume('LEFT_PAREN', 'MissingLeftParenthesisBeforeIfCondition')
    const condition = this.expression()
    this.consume('RIGHT_PAREN', 'MissingRightParenthesisAfterIfCondition', {
      condition,
    })
    this.consume('LEFT_BRACE', 'MissingLeftBraceToStartIfBody')
    const thenBranch = this.blockStatement()
    let elseBranch = null

    if (this.match('ELSE')) {
      if (this.match('IF')) {
        elseBranch = this.ifStatement()
      } else {
        this.consume('LEFT_BRACE', 'MissingLeftBraceToStartElseBody')
        elseBranch = this.blockStatement()
      }
    }

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

  private repeatUntilGameOverStatement(): Statement {
    const begin = this.previous()

    this.consume('LEFT_BRACE', 'MissingLeftBraceToStartRepeatBody')
    this.consumeEndOfLine()

    const statements = this.block()

    return new RepeatUntilGameOverStatement(
      statements,
      Location.between(begin, this.previous())
    )
  }

  private whileStatement(): Statement {
    const begin = this.previous()
    this.consume('LEFT_PAREN', 'MissingLeftParenthesisAfterWhile')
    const condition = this.expression()
    this.consume('RIGHT_PAREN', 'MissingRightParenthesisAfterWhileCondition', {
      condition,
    })

    this.consume('LEFT_BRACE', 'MissingLeftBraceToStartWhileBody')
    this.consumeEndOfLine()

    const statements = this.block()

    return new WhileStatement(
      condition,
      statements,
      Location.between(begin, this.previous())
    )
  }

  private doWhileStatement(): Statement {
    const begin = this.previous()

    this.consume('LEFT_BRACE', 'MissingLeftBraceToStartDoWhileBody')
    this.consumeEndOfLine()

    const statements = this.block()

    this.consume('WHILE', 'MissingWhileBeforeDoWhileCondition')

    this.consume('LEFT_PAREN', 'MissingLeftParenthesisAfterDoWhile')
    const condition = this.expression()
    this.consume(
      'RIGHT_PAREN',
      'MissingRightParenthesisAfterDoWhileCondition',
      {
        condition,
      }
    )

    this.consumeEndOfLine()

    return new DoWhileStatement(
      condition,
      statements,
      Location.between(begin, this.previous())
    )
  }

  private foreachStatement(): Statement {
    const foreachToken = this.previous()
    this.consume('LEFT_PAREN', 'MissingLeftParenthesisAfterForeach')
    this.consume('LET', 'MissingLetInForeachCondition')
    const elementName = this.consume(
      'IDENTIFIER',
      'MissingElementNameAfterForeach'
    )
    this.consume('OF', 'MissingOfAfterElementNameInForeach', {
      elementName,
    })
    const iterable = this.expression()

    this.consume('RIGHT_PAREN', 'MissingRightParenthesisAfterForeachElement', {
      iterable,
    })
    this.consume('LEFT_BRACE', 'MissingLeftBraceToStartForeachBody')
    this.consumeEndOfLine()

    const statements = this.block()

    return new ForeachStatement(
      elementName,
      iterable,
      statements,
      Location.between(foreachToken, this.previous())
    )
  }

  private blockStatement(): BlockStatement {
    const leftBraceToken = this.previous()
    this.consumeEndOfLine()
    const statements = this.block()

    return new BlockStatement(
      statements,
      Location.between(leftBraceToken, this.previous())
    )
  }

  private block(): Statement[] {
    const statements: Statement[] = []

    while (!this.check('RIGHT_BRACE') && !this.isAtEnd()) {
      statements.push(this.statement())
    }

    this.consume('RIGHT_BRACE', 'MissingRightBraceAfterBlock')
    this.consumeEndOfLine()
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
    const expr = this.ternary()

    if (
      this.match(
        'EQUAL',
        'SLASH_EQUAL',
        'STAR_EQUAL',
        'PLUS_EQUAL',
        'MINUS_EQUAL'
      )
    ) {
      const operator = this.previous()
      const value = this.assignment()

      if (expr instanceof VariableExpression) {
        return new AssignExpression(
          expr.name,
          operator,
          value,
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

  private ternary(): Expression {
    const expr = this.or()

    if (this.match('QUESTION_MARK')) {
      const then = this.ternary()
      this.consume('COLON', 'MissingColonAfterThenBranchOfTernaryOperator', {
        then,
      })
      const else_ = this.ternary()
      return new TernaryExpression(
        expr,
        then,
        else_,
        Location.between(expr, else_)
      )
    }

    return expr
  }

  private or(): Expression {
    const expr = this.and()

    while (this.match('OR', 'PIPE_PIPE')) {
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

    while (this.match('AND', 'AMPERSAND_AMPERSAND')) {
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

    while (
      this.match(
        'EQUALITY',
        'STRICT_INEQUALITY',
        'INEQUALITY',
        'STRICT_EQUALITY'
      )
    ) {
      const operator = this.previous()
      const right = this.comparison()
      expr = new BinaryExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private comparison(): Expression {
    let expr = this.term()

    while (this.match('GREATER', 'GREATER_EQUAL', 'LESS', 'LESS_EQUAL')) {
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

    while (this.match('SLASH', 'STAR')) {
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

    return this.postfix()
  }

  private postfix(): Expression {
    const expression = this.call()

    if (this.match('PLUS_PLUS', 'MINUS_MINUS')) {
      const operator = this.previous()

      return new UpdateExpression(
        expression,
        operator,
        Location.between(operator, expression)
      )
    }

    return expression
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
      const rparen = this.consume(
        'RIGHT_PAREN',
        'MissingRightParenthesisAfterExpression',
        {
          expression,
        }
      )
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
    this.consume('EOL', 'MissingEndOfLine')
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

  private isAtEndOfStatement(): boolean {
    return this.peek().type == 'EOL' || this.isAtEnd()
  }

  private peek(): Token {
    return this.tokens[this.current]
  }

  private previous(): Token {
    return this.tokens[this.current - 1]
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
