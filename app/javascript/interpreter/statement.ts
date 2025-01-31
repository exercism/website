import {
  EvaluationResult,
  EvaluationResultChangeVariableStatement,
  EvaluationResultReturnStatement,
  EvaluationResultSetVariableStatement,
} from './evaluation-result'
import { Expression, LiteralExpression } from './expression'
import { SomethingWithLocation } from './interpreter'
import { Location } from './location'
import type { Token } from './token'
import { formatLiteral } from './helpers'

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
    public keyword: Token,
    public count: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super('RepeatStatement')
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
}

export class RepeatUntilGameOverStatement extends Statement {
  constructor(
    public keyword: Token,
    public body: Statement[],
    public location: Location
  ) {
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
}
