import {
  EvaluationResult,
  EvaluationResultSetVariableStatement,
} from './evaluation-result'
import { Expression } from './expression'
import { Location } from './location'
import type { Token } from './token'

export abstract class Statement {
  abstract location: Location
}

export class ExpressionStatement extends Statement {
  constructor(public expression: Expression, public location: Location) {
    super()
  }
}

export class SetVariableStatement extends Statement {
  constructor(
    public name: Token,
    public initializer: Expression,
    public location: Location
  ) {
    super()
  }

  public description(result: EvaluationResultSetVariableStatement) {
    return `<p>This created a new variable called <code>${result.name}</code> and sets its value to <code>${result.value}</code>.</p>`
  }
}

export class ConstantStatement extends Statement {
  constructor(
    public name: Token,
    public initializer: Expression,
    public location: Location
  ) {
    super()
  }
}

export class IfStatement extends Statement {
  constructor(
    public condition: Expression,
    public thenBranch: Statement,
    public elseBranch: Statement | null,
    public location: Location
  ) {
    super()
  }
}

export class RepeatStatement extends Statement {
  constructor(
    public count: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super()
  }
}

export class RepeatUntilGameOverStatement extends Statement {
  constructor(public body: Statement[], public location: Location) {
    super()
  }
}

export class WhileStatement extends Statement {
  constructor(
    public condition: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super()
  }
}

export class DoWhileStatement extends Statement {
  constructor(
    public condition: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super()
  }
}

export class BlockStatement extends Statement {
  constructor(public statements: Statement[], public location: Location) {
    super()
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
    super()
  }
}

export class ReturnStatement extends Statement {
  constructor(
    public keyword: Token,
    public value: Expression | null,
    public location: Location
  ) {
    super()
  }
}

export class ForeachStatement extends Statement {
  constructor(
    public elementName: Token,
    public iterable: Expression,
    public body: Statement[],
    public location: Location
  ) {
    super()
  }
}
