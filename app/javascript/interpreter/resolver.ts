import { isString } from './checks'
import { SemanticError, type SemanticErrorType } from './error'
import {
  ArrayExpression,
  AssignExpression,
  BinaryExpression,
  CallExpression,
  DictionaryExpression,
  Expression,
  type ExpressionVisitor,
  GetExpression,
  GroupingExpression,
  LiteralExpression,
  LogicalExpression,
  SetExpression,
  TemplateLiteralExpression,
  TemplatePlaceholderExpression,
  TemplateTextExpression,
  TernaryExpression,
  UnaryExpression,
  UpdateExpression,
  VariableExpression,
} from './expression'
import { Location } from './location'
import {
  BlockStatement,
  ConstantStatement,
  DoWhileStatement,
  ExpressionStatement,
  ForeachStatement,
  FunctionStatement,
  IfStatement,
  RepeatStatement,
  RepeatUntilGameOverStatement,
  ReturnStatement,
  Statement,
  type StatementVisitor,
  VariableStatement,
  WhileStatement,
} from './statement'
import type { Token } from './token'
import { translate } from './translator'

type FunctionType = 'NONE' | 'FUNCTION'

export class Resolver
  implements ExpressionVisitor<void>, StatementVisitor<void>
{
  private readonly scopes: Map<string, boolean>[] = []
  private readonly constants = new Set<string>()
  private currentFunction: FunctionType = 'NONE'
  public readonly locals = new Map<Expression, number>()

  constructor(
    private allowVariableReassignment: boolean,
    private globals: string[]
  ) {
    this.beginScope()

    for (const key of globals) {
      this.declare(key)
      this.define(key)
    }
  }

  public visitExpressionStatement(statement: ExpressionStatement): void {
    this.resolve(statement.expression)
  }

  public visitVariableStatement(statement: VariableStatement): void {
    this.declare(statement.name)
    this.resolve(statement.initializer)
    this.define(statement.name)
  }

  public visitConstantStatement(statement: ConstantStatement): void {
    this.declareConstant(statement.name)
    this.resolve(statement.initializer)
    this.define(statement.name)
  }

  public visitIfStatement(statement: IfStatement): void {
    this.resolve(statement.condition)
    this.resolve(statement.thenBranch)
    if (statement.elseBranch !== null) this.resolve(statement.elseBranch)
  }

  public visitRepeatStatement(statement: RepeatStatement): void {
    this.resolve(statement.count)
    this.resolve(statement.body)
  }

  public visitRepeatUntilGameOverStatement(
    statement: RepeatUntilGameOverStatement
  ): void {
    this.resolve(statement.body)
  }

  public visitWhileStatement(statement: WhileStatement): void {
    this.resolve(statement.condition)
    this.resolve(statement.body)
  }

  public visitDoWhileStatement(statement: DoWhileStatement): void {
    this.resolve(statement.condition)
    this.resolve(statement.body)
  }

  public visitBlockStatement(statement: BlockStatement): void {
    this.beginScope()
    this.resolve(statement.statements)
    this.endScope()
  }

  public visitFunctionStatement(statement: FunctionStatement): void {
    this.declare(statement.name)
    this.define(statement.name)
    this.resolveFunction(statement, 'FUNCTION')
  }

  public visitReturnStatement(statement: ReturnStatement): void {
    if (this.currentFunction === 'NONE')
      this.error('TopLevelReturn', statement.location)

    if (statement.value !== null) this.resolve(statement.value)
  }

  visitForeachStatement(statement: ForeachStatement): void {
    this.resolve(statement.iterable)
    this.beginScope()
    this.declare(statement.elementName)
    this.define(statement.elementName)
    this.resolve(statement.body)
    this.endScope()
  }

  visitTemplateLiteralExpression(expression: TemplateLiteralExpression): void {
    for (const part of expression.parts) this.resolve(part)
  }

  visitTemplatePlaceholderExpression(
    expression: TemplatePlaceholderExpression
  ): void {
    this.resolve(expression.inner)
  }

  visitTemplateTextExpression(_expression: TemplateTextExpression): void {}

  visitArrayExpression(expression: ArrayExpression): void {
    for (const element of expression.elements) this.resolve(element)
  }

  visitDictionaryExpression(expression: DictionaryExpression): void {
    for (const [_, value] of expression.elements) this.resolve(value)
  }

  public visitCallExpression(expression: CallExpression): void {
    this.resolve(expression.callee)

    for (const arg of expression.args) this.resolve(arg)
  }

  public visitLiteralExpression(_expression: LiteralExpression): void {}

  public visitVariableExpression(expression: VariableExpression): void {
    if (this.globals && this.globals[expression.name.lexeme]) return

    if (
      this.scopes.length > 0 &&
      this.scopes[this.scopes.length - 1].has(expression.name.lexeme) &&
      !this.scopes[this.scopes.length - 1].get(expression.name.lexeme)
    )
      this.error('VariableUsedInOwnInitializer', expression.location, {
        expression,
        name: expression.name.lexeme,
      })

    this.resolveLocal(expression, expression.name)
  }

  public visitUnaryExpression(expression: UnaryExpression): void {
    this.resolve(expression.operand)
  }

  public visitBinaryExpression(expression: BinaryExpression): void {
    this.resolve(expression.left)
    this.resolve(expression.right)
  }

  public visitLogicalExpression(expression: LogicalExpression): void {
    this.resolve(expression.left)
    this.resolve(expression.right)
  }

  public visitTernaryExpression(expression: TernaryExpression): void {
    this.resolve(expression.condition)
    this.resolve(expression.thenBranch)
    this.resolve(expression.elseBranch)
  }

  public visitGroupingExpression(expression: GroupingExpression): void {
    this.resolve(expression.inner)
  }

  public visitAssignExpression(expression: AssignExpression): void {
    this.resolve(expression.value)

    if (this.constants.has(expression.name.lexeme))
      this.error('CannotAssignToConstant', expression.location)

    this.resolveLocal(expression, expression.name)
  }

  public visitUpdateExpression(expression: UpdateExpression): void {
    this.resolve(expression.operand)

    if (expression.operand instanceof VariableExpression)
      this.resolveLocal(expression.operand, expression.operand.name)
    else if (expression.operand instanceof GetExpression)
      this.resolve(expression.operand.obj)
    else this.error('InvalidPostfixOperand', expression.location)
  }

  public visitGetExpression(expression: GetExpression): void {
    this.resolve(expression.obj)
  }

  public visitSetExpression(expression: SetExpression): void {
    this.resolve(expression.obj)
    this.resolve(expression.value)
  }

  public resolve(element: Statement | Expression | Statement[]) {
    if (element instanceof Statement || element instanceof Expression) {
      element.accept(this)
      return
    }

    for (const statement of element) this.resolve(statement)
  }

  private resolveLocal(expression: VariableExpression, name: Token) {
    for (let i = this.scopes.length - 1; i >= 0; i--) {
      if (this.scopes[i].has(name.lexeme)) {
        if (this.constants.has(name.lexeme))
          this.error('CannotAssignToConstant', expression.location)

        this.setLocal(expression, this.scopes.length - 1 - i)
        return
      }
    }
  }

  private resolveFunction(
    statement: FunctionStatement,
    functionType: FunctionType
  ) {
    const enclosingFunction = this.currentFunction
    this.currentFunction = functionType

    this.beginScope()
    for (const param of statement.parameters) {
      this.declare(param.name)
      this.define(param.name)
    }
    this.resolve(statement.body)
    this.endScope()
    this.currentFunction = enclosingFunction
  }

  private declareConstant(name: Token | string) {
    this.constants.add(isString(name) ? name : name.lexeme)
    this.declare(name)
  }

  private declare(name: Token | string) {
    if (this.scopes.length === 0) return

    const nameString = isString(name) ? name : name.lexeme

    if (this.allowVariableReassignment) {
      if (this.scopes.find((scope) => scope.has(nameString))) {
        return
      }
    } else {
      const scope = this.scopes[this.scopes.length - 1]
      if (scope.has(nameString)) {
        this.error(
          'DuplicateVariableName',
          isString(name) ? null : name.location,
          {
            name,
          }
        )
      }
    }

    this.scopes[this.scopes.length - 1].set(nameString, false)
  }

  private define(name: Token | string) {
    if (this.scopes.length === 0) return
    this.scopes[this.scopes.length - 1].set(
      isString(name) ? name : name.lexeme,
      true
    )
  }

  private beginScope() {
    this.scopes.push(new Map())
  }

  private endScope() {
    this.scopes.pop()
  }

  private setLocal(expression: Expression, depth: number): void {
    this.locals.set(expression, depth)
  }

  private error(
    type: SemanticErrorType,
    location: Location | null,
    context: any = {}
  ): never {
    throw new SemanticError(
      translate(`error.semantic.${type}`, context),
      location,
      type,
      context
    )
  }
}
