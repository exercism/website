import {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
  EvaluationResultSetVariableStatement,
} from './evaluation-result'
import { Expression } from './expression'
import { SomethingWithLocation } from './interpreter'
import { Location } from './location'
import type { Token } from './token'

function quoteLiteral(value: any): string {
  if (typeof value === 'string') {
    return `"${value}"`
  }
  return value
}
export abstract class Statement implements SomethingWithLocation {
  constructor(public type: String) {}
  abstract location: Location
}

export class ExpressionStatement extends Statement {
  constructor(public expression: Expression, public location: Location) {
    super('ExpressionStatement')
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

  public description(result: EvaluationResultSetVariableStatement) {
    return `<p>This created a new variable called <code>${
      result.name
    }</code> and sets its value to <code>${quoteLiteral(
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

  public description(result: EvaluationResultChangeVariableStatement) {
    let output = `<p>This updated the variable called <code>${result.name}</code> from...</p>`
    output += `<pre><code>${quoteLiteral(result.oldValue)}</code></pre>`
    output += `<p>to...</p><pre><code>${quoteLiteral(
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
}

export class RepeatStatement extends Statement {
  constructor(
    public count: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('RepeatStatement')
  }
}

export class RepeatUntilGameOverStatement extends Statement {
  constructor(public body: Statement[], public location: Location) {
    super('RepeatUntilGameOverStatement')
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
}

export class DoWhileStatement extends Statement {
  constructor(
    public condition: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('DoWhileStatement')
  }
}

export class BlockStatement extends Statement {
  constructor(public statements: Statement[], public location: Location) {
    super('BlockStatement')
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
}

export class ReturnStatement extends Statement {
  constructor(
    public keyword: Token,
    public value: Expression | null,
    public location: Location
  ) {
    super('ReturnStatement')
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
}
