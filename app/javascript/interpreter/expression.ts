import type { Token } from './token'
import { Location } from './location'
import { FrameWithResult } from './frames'
import { EvaluationResult } from './evaluation-result'

function quoteLiteral(value: any): string {
  if (typeof value === 'string') {
    return `"${value}"`
  }
  return value
}

export abstract class Expression {
  constructor(public type: String) {}
  abstract location: Location
}

export class LiteralExpression extends Expression {
  constructor(public value: any, public location: Location) {
    super('LiteralExpression')
  }
  public description() {
    return `<code>${quoteLiteral(this.value)}</code>`
  }
}

export class VariableExpression extends Expression {
  constructor(public name: Token, public location: Location) {
    super('VariableExpression')
  }
  public description() {
    return `the <code>${this.name.lexeme}</code> variable`
  }
}

export class CallExpression extends Expression {
  constructor(
    public callee: VariableExpression,
    public paren: Token,
    public args: Expression[],
    public location: Location
  ) {
    super('CallExpression')
  }
}

export class ArrayExpression extends Expression {
  constructor(public elements: Expression[], public location: Location) {
    super('ArrayExpression')
  }
}

export class DictionaryExpression extends Expression {
  constructor(
    public elements: Map<string, Expression>,
    public location: Location
  ) {
    super('DictionaryExpression')
  }
}

export class BinaryExpression extends Expression {
  constructor(
    public left: Expression,
    public operator: Token,
    public right: Expression,
    public location: Location
  ) {
    super('BinaryExpression')
  }
}

export class LogicalExpression extends Expression {
  constructor(
    public left: Expression,
    public operator: Token,
    public right: Expression,
    public location: Location
  ) {
    super('LogicalExpression')
  }
}

export class UnaryExpression extends Expression {
  constructor(
    public operator: Token,
    public operand: Expression,
    public location: Location
  ) {
    super('UnaryExpression')
  }
}

export class GroupingExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super('GroupingExpression')
  }
}

export class TemplatePlaceholderExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super('TemplatePlaceholderExpression')
  }
}

export class TemplateTextExpression extends Expression {
  constructor(public text: Token, public location: Location) {
    super('TemplateTextExpression')
  }
}

export class TemplateLiteralExpression extends Expression {
  constructor(public parts: Expression[], public location: Location) {
    super('TemplateLiteralExpression')
  }
}

export class UpdateExpression extends Expression {
  constructor(
    public operand: Expression,
    public operator: Token,
    public location: Location
  ) {
    super('UpdateExpression')
  }
}

export class GetExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Token,
    public location: Location
  ) {
    super('GetExpression')
  }
}

export class SetExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Token,
    public value: Expression,
    public location: Location
  ) {
    super('SetExpression')
  }
}
