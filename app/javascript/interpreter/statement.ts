import {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
  EvaluationResultReturnStatement,
  EvaluationResultSetVariableStatement,
} from './evaluation-result'
import {
  CallExpression,
  Expression,
  VariableLookupExpression,
} from './expression'
import { SomethingWithLocation } from './interpreter'
import { Location } from './location'
import type { Token } from './token'
import { formatLiteral } from './helpers'

export abstract class Statement implements SomethingWithLocation {
  constructor(public type: String) {}
  abstract location: Location
  abstract children()
}

export class CallStatement extends Statement {
  constructor(public expression: CallExpression, public location: Location) {
    super('CallStatement')
  }
  public children() {
    return [this.expression]
  }
}

export class SetVariableStatement extends Statement {
  constructor(
    public name: Token,
    public value: Expression,
    public location: Location
  ) {
    super('SetVariableStatement')
  }
  public children() {
    return [this.value]
  }
}

export class ChangeVariableStatement extends Statement {
  constructor(
    public name: Token,
    public value: Expression,
    public location: Location
  ) {
    super('ChangeVariableStatement')
  }
  public children() {
    return [this.value]
  }
}

export class ChangeListElementStatement extends Statement {
  constructor(
    public list: Expression,
    public index: Expression,
    public value: Expression,
    public location: Location
  ) {
    super('ChangeListElementStatement')
  }
  public children() {
    return [this.list, this.index, this.value]
  }
}

export class ConstantStatement extends Statement {
  constructor(
    public name: Token,
    public initializer: Expression,
    public location: Location
  ) {
    super('ConstantStatement')
  }
  public children() {
    return [this.initializer]
  }
}

export class IfStatement extends Statement {
  constructor(
    public condition: Expression,
    public thenBranch: Statement,
    public elseBranch: Statement | null,
    public location: Location
  ) {
    super('IfStatement')
  }
  public children() {
    return [this.condition, this.thenBranch, this.elseBranch].flat()
  }
}

export class RepeatStatement extends Statement {
  constructor(
    public keyword: Token,
    public count: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('RepeatStatement')
  }
  public children() {
    return [this.count].concat(this.body)
  }
}

export class RepeatForeverStatement extends Statement {
  constructor(
    public keyword: Token,
    public body: Statement[],
    public location: Location
  ) {
    super('RepeatForeverStatement')
  }
  public children() {
    return this.body
  }
}

export class RepeatUntilGameOverStatement extends Statement {
  constructor(
    public keyword: Token,
    public body: Statement[],
    public location: Location
  ) {
    super('RepeatUntilGameOverStatement')
  }
  public children() {
    return this.body
  }
}

export class WhileStatement extends Statement {
  constructor(
    public condition: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('WhileStatement')
  }
  public children() {
    return [this.condition].concat(this.body)
  }
}

export class DoWhileStatement extends Statement {
  constructor(
    public condition: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('DoWhileStatement')
  }
  public children() {
    return [this.condition].concat(this.body)
  }
}

export class BlockStatement extends Statement {
  constructor(public statements: Statement[], public location: Location) {
    super('BlockStatement')
  }
  public children() {
    return this.statements
  }
}

export class FunctionParameter {
  constructor(public name: Token, public defaultValue: Expression | null) {}
}

export class FunctionStatement extends Statement {
  constructor(
    public name: Token,
    public parameters: FunctionParameter[],
    public body: Statement[],
    public location: Location
  ) {
    super('FunctionStatement')
  }
  public children() {
    return this.body
  }
}

export class ReturnStatement extends Statement {
  constructor(
    public keyword: Token,
    public expression: Expression | null,
    public location: Location
  ) {
    super('ReturnStatement')
  }
  public children() {
    return [this.expression].flat()
  }
}

export class ForeachStatement extends Statement {
  constructor(
    public elementName: Token,
    public iterable: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('ForeachStatement')
  }
  public children() {
    return [this.iterable].concat(this.body)
  }
}

export class LogStatement extends Statement {
  constructor(public expression: Expression, public location: Location) {
    super('LogStatement')
  }
  public children() {
    return []
  }
}
