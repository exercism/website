import type { Token } from './token'
import { Location } from './location'
import { EvaluationResultFunctionCallExpression } from './evaluation-result'
import { SomethingWithLocation } from './interpreter'
import { formatJikiObject } from './helpers'

export abstract class Expression implements SomethingWithLocation {
  constructor(public type: String) {}
  abstract location: Location
  abstract children(): Expression[]
}

export class LiteralExpression extends Expression {
  constructor(
    public value: number | string | boolean,
    public location: Location
  ) {
    super('LiteralExpression')
  }
  public children() {
    return []
  }
}

export class VariableLookupExpression extends Expression {
  constructor(public name: Token, public location: Location) {
    super('VariableLookupExpression')
  }
  public children() {
    return []
  }
}

export class FunctionLookupExpression extends Expression {
  constructor(public name: Token, public location: Location) {
    super('FunctionLookupExpression')
  }
  public children() {
    return []
  }
}
export class FunctionCallExpression extends Expression {
  constructor(
    public callee: FunctionLookupExpression,
    public args: Expression[],
    public location: Location
  ) {
    super('FunctionCallExpression')
  }
  public children() {
    return ([this.callee] as Expression[]).concat(this.args)
  }
}
export class MethodCallExpression extends Expression {
  constructor(
    public object: Expression,
    public methodName: Token,
    public args: Expression[],
    public location: Location
  ) {
    super('MethodCallExpression')
  }
  public children() {
    return ([this.object] as Expression[]).concat(this.args)
  }
}

export class ListExpression extends Expression {
  constructor(public elements: Expression[], public location: Location) {
    super('ListExpression')
  }
  public children() {
    return this.elements
  }
}

export class DictionaryExpression extends Expression {
  constructor(
    public elements: Map<string, Expression>,
    public location: Location
  ) {
    super('DictionaryExpression')
  }
  public children() {
    return Array.from(this.elements.values())
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
  public children() {
    return [this.left, this.right]
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
  public children() {
    return [this.left, this.right]
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
  public children() {
    return [this.operand]
  }
}

export class GroupingExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super('GroupingExpression')
  }
  public children() {
    return [this.inner]
  }
}

export class TemplatePlaceholderExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super('TemplatePlaceholderExpression')
  }
  public children() {
    return [this.inner]
  }
}

export class TemplateTextExpression extends Expression {
  constructor(public text: Token, public location: Location) {
    super('TemplateTextExpression')
  }
  public children() {
    return []
  }
}

export class TemplateLiteralExpression extends Expression {
  constructor(public parts: Expression[], public location: Location) {
    super('TemplateLiteralExpression')
  }
  public children() {
    return this.parts
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
  public children() {
    return [this.operand]
  }
}

export class GetElementExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Expression,
    public location: Location
  ) {
    super('GetElementExpression')
  }
  public children() {
    return [this.obj, this.field]
  }
}

export class SetElementExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Token,
    public value: Expression,
    public location: Location
  ) {
    super('SetElementExpression')
  }
  public children() {
    return [this.obj, this.value]
  }
}
