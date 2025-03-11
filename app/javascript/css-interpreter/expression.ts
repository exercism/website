import { Location } from './location'

export abstract class Expression {
  constructor(public type: String) {}
  abstract location: Location
  abstract children(): Expression[]
}

export class ValueExpression extends Expression {
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
