import { Expression } from './expression'
import { Location } from './location'
import type { Token } from './token'

export interface StatementVisitor<T> {
  visitExpressionStatement(statement: ExpressionStatement): T
  visitVariableStatement(statement: VariableStatement): T
  visitConstantStatement(statement: ConstantStatement): T
  visitIfStatement(statement: IfStatement): T
  visitRepeatStatement(statement: RepeatStatement): T
  visitRepeatUntilGameOverStatement(statement: RepeatUntilGameOverStatement): T
  visitBlockStatement(statement: BlockStatement): T
  visitFunctionStatement(statement: FunctionStatement): T
  visitReturnStatement(statement: ReturnStatement): T
  visitForeachStatement(statement: ForeachStatement): T
  visitWhileStatement(statement: WhileStatement): T
  visitDoWhileStatement(statement: DoWhileStatement): T
}

export abstract class Statement {
  abstract accept<T>(visitor: StatementVisitor<T>): T
  abstract location: Location
}

export class ExpressionStatement extends Statement {
  constructor(public expression: Expression, public location: Location) {
    super()
  }

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitExpressionStatement(this)
  }
}

export class VariableStatement extends Statement {
  constructor(
    public name: Token,
    public initializer: Expression,
    public location: Location
  ) {
    super()
  }

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitVariableStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitConstantStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitIfStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitRepeatStatement(this)
  }
}

export class RepeatUntilGameOverStatement extends Statement {
  constructor(public body: Statement[], public location: Location) {
    super()
  }

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitRepeatUntilGameOverStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitWhileStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitDoWhileStatement(this)
  }
}

export class BlockStatement extends Statement {
  constructor(public statements: Statement[], public location: Location) {
    super()
  }

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitBlockStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitFunctionStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitReturnStatement(this)
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

  public accept<T>(visitor: StatementVisitor<T>): T {
    return visitor.visitForeachStatement(this)
  }
}
