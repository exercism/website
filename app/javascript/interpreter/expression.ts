import type { Token } from './token'
import { Location } from './location'
import { FrameWithResult } from './frames'

export abstract class Expression {
  abstract location: Location

  protected addExtraAssignInfoForDescription(frame: FrameWithResult) {
    if (frame.result?.value == null) {
      return '<p><code>null</code> is a special keyword that signifies the lack of a real value. It is often used as a placeholder before we know what we should set a value to.</p>'
    }

    return null
  }
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
}

export class LiteralExpression extends Expression {
  constructor(public value: any, public location: Location) {
    super()
  }
  public description() {
    let value = this.value
    if (typeof this.value === 'string') {
      value = '"' + this.value + '"'
    }

    return `<code>${value}</code>`
  }
}

export class ArrayExpression extends Expression {
  constructor(public elements: Expression[], public location: Location) {
    super()
  }
}

export class DictionaryExpression extends Expression {
  constructor(
    public elements: Map<string, Expression>,
    public location: Location
  ) {
    super()
  }
}

export class VariableExpression extends Expression {
  constructor(public name: Token, public location: Location) {
    super()
  }
  public description() {
    return `the <code>${this.name.lexeme}</code> variable`
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
}

export class UnaryExpression extends Expression {
  constructor(
    public operator: Token,
    public operand: Expression,
    public location: Location
  ) {
    super()
  }
}

export class GroupingExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super()
  }
}

export class TemplatePlaceholderExpression extends Expression {
  constructor(public inner: Expression, public location: Location) {
    super()
  }
}

export class TemplateTextExpression extends Expression {
  constructor(public text: Token, public location: Location) {
    super()
  }
}

export class TemplateLiteralExpression extends Expression {
  constructor(public parts: Expression[], public location: Location) {
    super()
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

  public description(frame: FrameWithResult) {
    let output = `<p>This updated the variable called <code>${frame.result.name}</code> to <code>${frame.result.value.value}</code>.</p>`
    const extra = this.addExtraAssignInfoForDescription(frame)
    if (extra) {
      output += extra
    }

    return output
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
}

export class GetExpression extends Expression {
  constructor(
    public obj: Expression,
    public field: Token,
    public location: Location
  ) {
    super()
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
}
