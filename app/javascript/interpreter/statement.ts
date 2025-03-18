import {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
  EvaluationResultReturnStatement,
  EvaluationResultSetVariableStatement,
} from './evaluation-result'
import {
  FunctionCallExpression,
  Expression,
  VariableLookupExpression,
  MethodCallExpression,
} from './expression'
import { SomethingWithLocation } from './interpreter'
import { Location } from './location'
import type { Token } from './token'
import { formatJikiObject } from './helpers'

export abstract class Statement implements SomethingWithLocation {
  constructor(public type: String) {}
  abstract location: Location
  abstract children()
}

export class FunctionCallStatement extends Statement {
  constructor(
    public expression: FunctionCallExpression,
    public location: Location
  ) {
    super('FunctionCallStatement')
  }
  public children() {
    return [this.expression]
  }
}
export class MethodCallStatement extends Statement {
  constructor(
    public expression: MethodCallExpression,
    public location: Location
  ) {
    super('MethodCallStatement')
  }
  public children() {
    return [this.expression]
  }
}

export class ChangeElementStatement extends Statement {
  constructor(
    public object: Expression,
    public field: Expression,
    public value: Expression,
    public location: Location
  ) {
    super('ChangeElementStatement')
  }
  public children() {
    return [this.object, this.field, this.value]
  }
}

export class ChangePropertyStatement extends Statement {
  constructor(
    public object: Expression,
    public property: Token,
    public value: Expression,
    public location: Location
  ) {
    super('ChangePropertyStatement')
  }
  public children() {
    return [this.object, this.value]
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
export class ChangeObjectPropertyStatement extends Statement {
  constructor(
    public name: Token,
    public value: Expression,
    public location: Location
  ) {
    super('ChangeObjectPropertyStatement')
  }
  public children() {
    return [this.value]
  }
}

export class BreakStatement extends Statement {
  constructor(public keyword: Token, public location: Location) {
    super('BreakStatement')
  }
  public children() {
    return []
  }
}

export class ContinueStatement extends Statement {
  constructor(public keyword: Token, public location: Location) {
    super('ContinueStatement')
  }
  public children() {
    return []
  }
}

export class ForeachStatement extends Statement {
  constructor(
    public elementName: Token,
    public secondElementName?: Token,
    public iterable: Expression,
    public counter: Token | null,
    public body: Statement[],
    public location: Location
  ) {
    super('ForeachStatement')
  }
  public children() {
    return [this.iterable].concat(this.body)
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
export class LogStatement extends Statement {
  constructor(public expression: Expression, public location: Location) {
    super('LogStatement')
  }
  public children() {
    return []
  }
}

export class RepeatStatement extends Statement {
  constructor(
    public keyword: Token,
    public count: Expression,
    public counter: Token | null,
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
    public counter: Token | null,
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
    public counter: Token | null,
    public body: Statement[],
    public location: Location
  ) {
    super('RepeatUntilGameOverStatement')
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

export class SetPropertyStatement extends Statement {
  constructor(
    public property: Token,
    public value: Expression,
    public location: Location
  ) {
    super('SetPropertyStatement')
  }
  public children() {
    return [this.value]
  }
}

/*export class ConstantStatement extends Statement {
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
}*/

/*export class WhileStatement extends Statement {
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
}*/

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

// OOP Shizzle
export class ClassStatement extends Statement {
  constructor(
    public name: Token,
    public body: Statement[],
    public location: Location
  ) {
    super('ClassStatement')
  }
  public children() {
    return this.body
  }
}

export class ConstructorStatement extends Statement {
  constructor(
    public parameters: FunctionParameter[],
    public body: Statement[],
    public location: Location
  ) {
    super('ConstructorStatement')
  }
  public children() {
    return this.body
  }
}
export class MethodStatement extends Statement {
  constructor(
    public accessModifier: Token,
    public name: Token,
    public parameters: FunctionParameter[],
    public body: Statement[],
    public location: Location
  ) {
    super('MethodStatement')
  }
  public children() {
    return this.body
  }
}
export class PropertyStatement extends Statement {
  constructor(
    public accessModifier: Token,
    public name: Token,
    public location: Location
  ) {
    super('PropertyStatement')
  }
  public children() {
    return []
  }
}
