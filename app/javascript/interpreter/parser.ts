import { SyntaxError } from './error'
import { type SyntaxErrorType } from './error'
import {
  ListExpression,
  BinaryExpression,
  FunctionCallExpression,
  Expression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  DictionaryExpression,
  UnaryExpression,
  VariableLookupExpression,
  GetElementExpression,
  SetElementExpression,
  TemplateLiteralExpression,
  TemplatePlaceholderExpression,
  TemplateTextExpression,
  FunctionLookupExpression,
  MethodCallExpression,
} from './expression'
import type { LanguageFeatures } from './interpreter'
import { Location } from './location'
import { Scanner } from './scanner'
import {
  BlockStatement,
  BreakStatement,
  FunctionCallStatement,
  ContinueStatement,
  ForeachStatement,
  FunctionParameter,
  FunctionStatement,
  IfStatement,
  RepeatStatement,
  RepeatUntilGameOverStatement,
  ReturnStatement,
  Statement,
  SetVariableStatement,
  ChangeVariableStatement,
  RepeatForeverStatement,
  LogStatement,
  ChangeElementStatement,
} from './statement'
import {
  KeywordTokens,
  StatementKeywordTokens,
  type Token,
  type TokenType,
} from './token'
import { translate } from './translator'
import { isTypo } from './helpers/isTypo'
import { errorForMissingDoAfterParameters } from './helpers/complexErrors'
import { formatJikiObject } from './helpers'
import { unwrapJikiObject } from './jikiObjects'

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

    const statements: Statement[] = []

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

        // If we have some keyword other than "DO", it's probably
        // someone using a reserved keyword by accident
        if (this.nextTokenIsKeyword() && !this.check('DO')) {
          this.error('UnexpectedKeyword', this.peek().location, {
            lexeme: this.peek().lexeme,
          })
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
    if (this.match('BREAK')) return this.breakStatement()
    if (this.match('CHANGE')) return this.changeVariableStatement()
    if (this.match('CONTINUE')) return this.continueStatement()
    if (this.match('NEXT')) return this.continueStatement()
    if (this.match('IF')) return this.ifStatement()
    if (this.match('LOG')) return this.logStatement()
    if (this.match('SET')) return this.setVariableStatement()
    if (this.match('RETURN')) return this.returnStatement()
    if (this.match('REPEAT')) return this.repeatStatement()
    if (this.match('REPEAT_FOREVER')) return this.repeatForeverStatement()
    if (this.match('REPEAT_UNTIL_GAME_OVER'))
      return this.repeatUntilGameOverStatement()
    // if (this.match('WHILE')) return this.whileStatement()
    if (this.match('FOR')) return this.forStatement()
    if (this.match('DO')) return this.blockStatement('do')

    // Error cases
    if (this.match('ELSE')) {
      this.error('UnexpectedElseWithoutIf', this.previous().location)
    }

    return this.callStatement()
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

  private setVariableStatement(): Statement {
    const setToken = this.previous()
    const name = this.identifier()

    // Guard mistaken equals sign for assignment
    this.guardEqualsSignForAssignment(this.peek())

    this.consume('TO', 'MissingToAfterVariableNameToInitializeValue', {
      name: name.lexeme,
    })

    const value = this.expression()
    this.consumeEndOfLine()

    return new SetVariableStatement(
      name,
      value,
      Location.between(setToken, value)
    )
  }

  private changeVariableStatement(): Statement {
    const changeToken = this.previous()

    // If we have a left bracket, we're changing an element in a list
    // not a variable, so move to that function instead
    if (this.peek(2).type == 'LEFT_BRACKET') {
      return this.changeListElementStatement(changeToken)
    }

    const name = this.identifier()

    // Guard mistaken equals sign for assignment
    this.guardEqualsSignForAssignment(this.peek())

    this.consume('TO', 'MissingToAfterVariableNameToInitializeValue', {
      name: name.lexeme,
    })

    const initializer = this.expression()
    this.consumeEndOfLine()

    return new ChangeVariableStatement(
      name,
      initializer,
      Location.between(changeToken, initializer)
    )
  }

  private changeListElementStatement(
    changeToken: Token
  ): ChangeElementStatement {
    // Convert the statement
    // change foobar[123] into a lookup expression for foobar[123]
    // and then we'll break down the foobar and the 123 as the list
    // and the index, while still maintaining the integrity of both sides.
    const getExpression = this.chainedVariableAccessors(this.primary())

    if (!(getExpression instanceof GetElementExpression)) {
      this.error('GenericSyntaxError', getExpression.location)
    }

    const list = getExpression.obj
    const index = getExpression.field

    // Guard mistaken equals sign for assignment
    this.guardEqualsSignForAssignment(this.peek())

    this.consume('TO', 'MissingToAfterVariableNameToInitializeValue', {
      name: list,
    })

    const value = this.expression()
    this.consumeEndOfLine()

    return new ChangeElementStatement(
      list,
      index,
      value,
      Location.between(changeToken, value)
    )
  }

  private ifStatement(): Statement {
    const ifToken = this.previous()
    let condition
    try {
      condition = this.expression()
    } catch (e) {
      if (e instanceof SyntaxError && e.type == 'MissingExpression') {
        this.error('MissingConditionAfterIf', ifToken.location)
      } else {
        throw e
      }
    }

    this.consumeDo('if')

    const thenBranch = this.blockStatement('if', {
      allowElse: true,
      consumeEnd: false,
    })
    let elseBranch: Statement | null = null

    if (this.match('ELSE')) {
      if (this.match('IF')) {
        elseBranch = this.ifStatement()
      } else {
        this.consumeDo('else')
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

  private logStatement(): Statement {
    const logToken = this.previous()
    const value = this.expression()
    this.consumeEndOfLine()

    return new LogStatement(value, Location.between(logToken, value))
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
    const keyword = this.previous()
    const condition = this.expression()
    this.consume('TIMES', 'MissingTimesInRepeat')
    const counter = this.counter()
    this.consumeDo('repeat')
    this.consumeEndOfLine()

    const statements = this.block('repeat')

    return new RepeatStatement(
      keyword,
      condition,
      counter,
      statements,
      Location.between(keyword, this.previous())
    )
  }

  private repeatUntilGameOverStatement(): Statement {
    const keyword = this.previous()

    const counter = this.counter()
    this.consumeDo('repeat_until_game_over')
    this.consumeEndOfLine()

    const statements = this.block('repeat_until_game_over')

    return new RepeatUntilGameOverStatement(
      keyword,
      counter,
      statements,
      Location.between(keyword, this.previous())
    )
  }
  private repeatForeverStatement(): Statement {
    const keyword = this.previous()
    const counter = this.counter()
    this.consumeDo('repeat_forever')
    this.consumeEndOfLine()

    const statements = this.block('repeat_forever')

    return new RepeatForeverStatement(
      keyword,
      counter,
      statements,
      Location.between(keyword, this.previous())
    )
  }

  /*private whileStatement(): Statement {
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
  }*/

  private forStatement(): Statement {
    const forToken = this.previous()
    const eachToken = this.consume('EACH', 'MissingEachAfterFor')
    return this.foreachStatement(forToken, eachToken)
  }
  private foreachStatement(forToken: Token, eachToken: Token): Statement {
    const elementName = this.consume(
      'IDENTIFIER',
      'MissingElementNameAfterForeach'
    )
    this.consume('IN', 'MissingOfAfterElementNameInForeach', {
      elementName,
    })
    const iterable = this.expression()
    const counter = this.counter()

    this.consumeDo('foreach')
    this.consumeEndOfLine()

    const statements = this.block('foreach')

    return new ForeachStatement(
      elementName,
      iterable,
      counter,
      statements,
      Location.between(forToken, this.previous())
    )
  }

  private counter(): Token | null {
    if (this.match('INDEXED')) {
      this.consume('BY', 'MissingByAfterIndexed')
      return this.consume('IDENTIFIER', 'MissingIndexNameAfterIndexedBy')
    }
    return null
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

  private callStatement(): Statement {
    let expression = this.expression()
    while (true) {
      if (expression instanceof FunctionCallExpression) {
        break
      }
      if (expression instanceof GroupingExpression) {
        expression = expression.inner
        continue
      }
      if (expression instanceof VariableLookupExpression) {
        this.error(
          'PotentialMissingParenthesesForFunctionCall',
          expression.location
        )
      }

      this.error('PointlessStatement', expression.location)
    }

    this.consumeEndOfLine()

    return new FunctionCallStatement(expression, expression.location)
  }

  private continueStatement(): ContinueStatement {
    const keyword = this.previous()
    this.consumeEndOfLine()

    return new ContinueStatement(keyword, keyword.location)
  }

  private breakStatement(): BreakStatement {
    const keyword = this.previous()
    this.consumeEndOfLine()

    return new BreakStatement(keyword, keyword.location)
  }

  private expression(): Expression {
    return this.assignment()
  }

  private assignment(): Expression {
    const expr = this.or()

    if (this.match('TO')) {
      const operator = this.previous()
      const value = this.or()

      if (expr instanceof GetElementExpression) {
        return new SetElementExpression(
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
    let expr = this.and()

    while (this.match('OR')) {
      let operator = this.previous()
      operator.type = 'OR'

      // Guard against someone writing if x and if y do
      if (this.check('IF')) {
        this.error('UnexpectedIfInBinaryExpression', this.peek().location)
      }

      const right = this.and()
      expr = new LogicalExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
    }

    return expr
  }

  private and(): Expression {
    let expr = this.equality()

    while (this.match('AND')) {
      let operator = this.previous()
      operator.type = 'AND'

      // Guard against someone writing if x and if y do
      if (this.check('IF')) {
        this.error('UnexpectedIfInBinaryExpression', this.peek().location)
      }

      const right = this.equality()
      expr = new LogicalExpression(
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

    const nextToken = this.peek()
    if (nextToken.type == 'EQUALITY' || nextToken.type == 'INEQUALITY') {
      const operator = this.advance()
      const right = this.comparison()
      expr = new BinaryExpression(
        expr,
        operator,
        right,
        Location.between(expr, right)
      )
      this.guardDoubleEquality()
    } else {
      this.guardEqualsSignForEquality(this.peek())
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

    return this.methodCall()
  }

  private methodCall(): Expression {
    let expr = this.functionCall()

    if (!this.match('DOT')) {
      return expr
    }
    const methodName = this.consume('IDENTIFIER', 'MissingMethodNameAfterDot')

    return this.chainedVariableAccessors(
      expr,
      (callee: VariableLookupExpression) => {
        const args: Expression[] = []

        if (this.match('EOL')) {
          this.error(
            'MissingRightParenthesisAfterMethodCall',
            methodName.location,
            {
              method: methodName.lexeme,
            }
          )
        }
        if (!this.check('RIGHT_PAREN')) {
          do {
            args.push(this.expression())
          } while (this.match('COMMA'))
        }

        const rightParen = this.consume(
          'RIGHT_PAREN',
          'MissingRightParenthesisAfterFunctionCall',
          {
            args,
            method: methodName.lexeme,
          }
        )
        return new MethodCallExpression(
          expr,
          methodName,
          args,
          Location.between(expr, rightParen)
        )
      }
    )
  }

  private functionCall(): Expression {
    let expression = this.primary()
    return this.chainedVariableAccessors(
      expression,
      (expression: Expression) => {
        if (!(expression instanceof VariableLookupExpression)) {
          this.error('InvalidFunctionName', expression.location, {})
        }

        // Mutate the callee to be a FunctionLookupExpression,
        // not a VariableLookupExpression so we can properly look things up
        // in the right scopes later on.
        let callee = expression as VariableLookupExpression
        callee = new FunctionLookupExpression(callee.name, callee.location)

        const args: Expression[] = []

        if (this.match('EOL')) {
          this.error(
            'MissingRightParenthesisAfterFunctionCall',
            callee.location,
            {
              function:
                callee instanceof FunctionLookupExpression
                  ? callee.name.lexeme
                  : null,
            }
          )
        }
        if (!this.check('RIGHT_PAREN')) {
          do {
            args.push(this.expression())
          } while (this.match('COMMA'))
        }

        const rightParen = this.consume(
          'RIGHT_PAREN',
          'MissingRightParenthesisAfterFunctionCall',
          {
            args,
            function:
              callee instanceof FunctionLookupExpression
                ? callee.name.lexeme
                : null,
          }
        )
        return new FunctionCallExpression(
          callee,
          args,
          Location.between(callee, rightParen)
        )
      }
    )
  }

  private chainedVariableAccessors(
    expression: Expression,
    finishCall: (
      elem: Expression
    ) => FunctionCallExpression | MethodCallExpression
  ): Expression {
    // Firstly handle this if it is a function call
    if (this.match('LEFT_PAREN')) {
      expression = finishCall(expression)
    }

    // Now handle an array (this might be on the result of the function call)
    // e.g. foobar()[0]
    while (this.match('LEFT_BRACKET')) {
      // const leftBracket = this.previous()
      const field = this.expression()
      const rightBracket = this.consume(
        'RIGHT_BRACKET',
        'MissingRightBracketAfterFieldNameOrIndex',
        { expression }
      )
      expression = new GetElementExpression(
        expression,
        field,
        Location.between(expression, rightBracket)
      )
    }
    return expression
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
      return new VariableLookupExpression(
        this.previous(),
        this.previous().location
      )

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

    if (this.peek().type == 'FUNCTION') {
      this.error('InvalidNestedFunction', this.peek().location)
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
      this.match('EOL') // Allow for the first element to be on a new line

      // Check for comma before anything else.
      this.guardTrailingComma('COMMA', this.peek().location)

      let moreItems = true
      let prevComma: Token | undefined

      while (moreItems) {
        moreItems = false

        try {
          elements.push(this.or())
        } catch (e) {
          if (!(e instanceof SyntaxError && e.type == 'MissingExpression')) {
            throw e
          }
          this.error(
            'MissingRightBracketAfterListElements',
            (prevComma || this.previous()).location
          )
        }

        // If we've got a comma, then we consume an end of line if it's there and go again
        if (this.check('COMMA')) {
          prevComma = this.consume('COMMA', 'MissingCommaInList')
          moreItems = true

          if (this.check('EOL')) {
            this.consumeEndOfLine()
          }

          // Check for trailing commas
          this.guardTrailingComma(
            'RIGHT_BRACKET',
            (prevComma || leftBracket).location
          )
        }
        // If there's no comma, we expect either a `]` or ` `\n]`.
        // Firstly check for the newline version, and consume the
        // newline if it's there.
        else if (this.check('EOL') && this.check('RIGHT_BRACKET', 2)) {
          this.consumeEndOfLine()
        }
        // Finally, we expect just a right bracket. If we don't have
        // that, we're probably missing a comma.
        else if (!this.check('RIGHT_BRACKET')) {
          if (this.nextTokenIsKeyword()) {
            this.error(
              'MissingRightBracketAfterListElements',
              leftBracket.location
            )
          }
          this.error('MissingCommaInList', this.peek().location)
        }
      }
    }

    const rightBracket = this.consume(
      'RIGHT_BRACKET',
      'MissingRightBracketAfterListElements',
      { elements }
    )
    return new ListExpression(
      elements,
      Location.between(leftBracket, rightBracket)
    )
  }

  private dictionary(): Expression {
    const leftBrace = this.previous()
    const elements = new Map<string, Expression>()

    if (!this.check('RIGHT_BRACE')) {
      this.match('EOL') // Allow for the first element to be on a new line

      // Check for trailing commas
      this.guardTrailingComma('COMMA', this.peek().location)

      let moreItems = true
      let prevComma: Token | undefined

      while (moreItems) {
        if (this.check('RIGHT_BRACE')) {
          this.error('UnexpectedTrailingComma', leftBrace.location)
        }
        if (this.nextTokenIsKeyword()) {
          this.error(
            'MissingRightBraceAfterDictionaryElements',
            leftBrace.location
          )
        }

        moreItems = false
        let key
        try {
          key = this.consume('STRING', 'MissingStringAsKey')
        } catch (e) {
          if (!(e instanceof SyntaxError && e.type == 'MissingExpression')) {
            throw e
          }
          this.error(
            'MissingRightBraceAfterDictionaryElements',
            (prevComma || this.previous()).location
          )
        }

        this.consume('COLON', 'MissingColonAfterKey')
        elements.set(key.literal, this.or())

        // If we have a comma, continue onwards
        if (this.match('COMMA')) {
          prevComma = this.previous()
          this.match('EOL') // Allow for things to be split over lines

          // Check for trailing commas
          this.guardTrailingComma(
            'RIGHT_BRACE',
            (prevComma || leftBrace).location
          )

          moreItems = !this.isAtEnd()
        }
        // If there's no comma, we expect either a `}` or ` `\n}`.
        // Firstly check for the newline version, and consume the
        // newline if it's there.
        else if (this.check('EOL') && this.check('RIGHT_BRACE', 2)) {
          this.consumeEndOfLine()
        }
        // Finally, we expect just a right bracket. If we don't have
        // that, we're either missing a comma or an end closing brace.
        else if (!this.check('RIGHT_BRACE')) {
          if (this.nextTokenIsKeyword()) {
            this.error(
              'MissingRightBraceAfterDictionaryElements',
              leftBrace.location
            )
          }
          this.error('MissingCommaInDictionary', this.peek().location)
        }
      }
    }

    const rightBracket = this.consume(
      'RIGHT_BRACE',
      'MissingRightBraceAfterDictionaryElements',
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

  private check(tokenType: TokenType, steps = 1): boolean {
    if (this.isAtEnd()) return false
    return this.peek(steps).type == tokenType
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
    // Unwrap context values from jiki objects
    context = unwrapJikiObject(context)

    throw new SyntaxError(
      translate(`error.syntax.${type}`, context),
      location,
      type,
      context
    )
  }

  private guardTrailingComma(
    token: 'COMMA' | 'RIGHT_BRACKET' | 'RIGHT_BRACE',
    location: Location
  ) {
    if (!this.check(token)) {
      return
    }
    this.error('UnexpectedTrailingComma', location)
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

  private guardDoubleEquality() {
    const nextToken = this.peek()
    if (nextToken.type == 'EQUALITY' || nextToken.type == 'INEQUALITY') {
      this.error('UnexpectedChainedEquality', nextToken.location)
    }
  }

  private isAtEnd(): boolean {
    return this.peek().type == 'EOF'
  }

  private isAtEndOfStatement(): boolean {
    return this.peek().type == 'EOL' || this.isAtEnd()
  }

  private nextTokenIsKeyword(): boolean {
    let counter = 1
    while (this.check('EOL', counter)) {
      counter++
    }
    const nextActualThing = this.peek(counter)

    return KeywordTokens.includes(nextActualThing.type)
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
