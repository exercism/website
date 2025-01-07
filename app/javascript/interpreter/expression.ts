import type { Token } from './token'
import { Location } from './location'

export interface ExpressionVisitor<T> {
  visitCallExpression(expression: CallExpression): T
  visitLiteralExpression(expression: LiteralExpression): T
  visitVariableExpression(expression: VariableExpression): T
  visitUnaryExpression(expression: UnaryExpression): T
  visitBinaryExpression(expression: BinaryExpression): T
  visitLogicalExpression(expression: LogicalExpression): T
  visitGroupingExpression(expression: GroupingExpression): T
  visitTemplateLiteralExpression(expression: TemplateLiteralExpression): T
  visitTemplatePlaceholderExpression(
    expression: TemplatePlaceholderExpression
  ): T
  visitTemplateTextExpression(expression: TemplateTextExpression): T
  visitAssignExpression(expression: AssignExpression): T
  visitUpdateExpression(expression: UpdateExpression): T
  visitArrayExpression(expression: ArrayExpression): T
  visitDictionaryExpression(expression: DictionaryExpression): T
  visitGetExpression(expression: GetExpression): T
  visitSetExpression(expression: SetExpression): T
  visitTernaryExpression(expression: TernaryExpression): T
}

export abstract class Expression {
  abstract accept<T>(visitor: ExpressionVisitor<T>): T
  abstract location: Location
}

export class CallExpression extends Expression {
  constructor(
    public callee: Expression,
    public paren: Token,
    public args: Expression[],
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitCallExpression(this)
  }
}

export class TernaryExpression extends Expression {
  constructor(
    public condition: Expression,
    public thenBranch: Expression,
    public elseBranch: Expression,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitTernaryExpression(this)
  }
}

export class LiteralExpression extends Expression {
  constructor(public value: any, public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitLiteralExpression(this)
  }
}

export class ArrayExpression extends Expression {
  constructor(public elements: Expression[], public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitArrayExpression(this)
  }
}

export class DictionaryExpression extends Expression {
  constructor(
    public elements: Map<string, Expression>,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitDictionaryExpression(this)
  }
}

export class VariableExpression extends Expression {
  constructor(public name: Token, public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitVariableExpression(this)
  }
}

export class BinaryExpression extends Expression {
  constructor(
    public left: Expression,
    public operator: Token,
    public right: Expression,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitBinaryExpression(this)
  }
}

export class LogicalExpression extends Expression {
  constructor(
    public left: Expression,
    public operator: Token,
    public right: Expression,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitLogicalExpression(this)
  }
}

export class UnaryExpression extends Expression {
  constructor(
    public operator: Token,
    public operand: Expression,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitUnaryExpression(this)
  }
}

export class GroupingExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitGroupingExpression(this)
  }
}

export class TemplatePlaceholderExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitTemplatePlaceholderExpression(this)
  }
}

export class TemplateTextExpression extends Expression {
  constructor(public text: Token, public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitTemplateTextExpression(this)
  }
}

export class TemplateLiteralExpression extends Expression {
  constructor(public parts: Expression[], public location: Location) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitTemplateLiteralExpression(this)
  }
}

export class AssignExpression extends Expression {
  constructor(
    public name: Token,
    public operator: Token,
    public value: Expression,
    public updating: boolean,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitAssignExpression(this)
  }
}

export class UpdateExpression extends Expression {
  constructor(
    public operand: Expression,
    public operator: Token,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitUpdateExpression(this)
  }
}

export class GetExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Token,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitGetExpression(this)
  }
}

export class SetExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Token,
    public value: Expression,
    public location: Location
  ) {
    super()
  }

  accept<T>(visitor: ExpressionVisitor<T>): T {
    return visitor.visitSetExpression(this)
  }
}
