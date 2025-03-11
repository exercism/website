import { ValueExpression } from './expression'
import { Location } from './location'
import type { Token } from './token'

export abstract class Statement {
  constructor(public type: String) {}
  abstract location: Location
}

export class SelectorStatement extends Statement {
  constructor(
    public selectors: Token[],
    public body: Statement[],
    public location: Location
  ) {
    super('SelectorStatement')
  }
}

export class PropertyStatement extends Statement {
  constructor(
    public property: Token,
    public value: ValueExpression,
    public location: Location
  ) {
    super('PropertyStatement')
  }
}
