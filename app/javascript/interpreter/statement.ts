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
    public initializer: Expression,
    public location: Location
  ) {
    super('SetVariableStatement')
  }
  public children() {
    return [this.initializer]
  }

  public description(result: EvaluationResultSetVariableStatement) {
    return `<p>This created a new variable called <code>${
      result.name
    }</code> and sets its value to <code>${formatLiteral(
      result.value
    )}</code>.</p>`
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

  public description(result: EvaluationResultChangeVariableStatement) {
    let output = `<p>This updated the variable called <code>${result.name}</code> from...</p>`
    output += `<pre><code>${formatLiteral(result.oldValue)}</code></pre>`
    output += `<p>to...</p><pre><code>${formatLiteral(
      result.newValue.value
    )}</code></pre>`
    return output
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
    public value: Expression | null,
    public location: Location
  ) {
    super('ReturnStatement')
  }
  public children() {
    return [this.value].flat()
  }
  public description(result: EvaluationResultReturnStatement) {
    if (result.value == undefined) {
      return `<p>This exited the function.</p>`
    }
    if (result.value.type == 'VariableLookupExpression') {
      return `<p>This returned the value of <code>${result.value.name}</code>, which in this case is <code>${result.value.value}</code>.</p>`
    }
    // if(result.value.type == "LiteralExpression") {
    else {
      return `<p>This returned <code>${result.value.value}</code>.</p>`
    }
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

  public description(result: EvaluationResult) {
    if (this.expression.type == 'VariableLookupExpression') {
      return `<p>This logged the value of <code>${
        (this.expression as VariableLookupExpression).name.lexeme
      }</code>, which was <code>${result.value.value}</code>.</p>`
    } else if (this.expression.type == 'CallExpression') {
      return `<p>This logged the value of <code>${(
        this.expression as CallExpression
      ).description()}</code>, which was <code>${
        result.value.value
      }</code>.</p>`
    }
    return `<p>This logged <code>${formatLiteral(
      result.value.value
    )}</code>.</p>`

    // return `<p>This logged <code>${this.value.description()}</code>.</p>`
    // return `<p>This logged <code>${formatLiteral(result.value)}</code>.</p>`
  }
}
