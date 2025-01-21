import { Expression } from './expression'
import { Statement } from './statement'
import { type Token } from './token'

export class Span {
  constructor(public begin: number, public end: number) {}

  public static between(from: Span, to: Span): Span {
    return new Span(from.begin, to.end)
  }
}

export class Location {
  constructor(
    public line: number,
    public relative: Span,
    public absolute: Span
  ) {}

  public toCode(code: string): string {
    return code.substring(this.absolute.begin - 1, this.absolute.end - 1)
  }

  public static fromLineOffset(
    begin: number,
    end: number,
    line: number,
    lineOffset: number
  ): Location {
    return new Location(
      line,
      new Span(begin - lineOffset, end - lineOffset),
      new Span(begin, end)
    )
  }

  public static between(
    begin: Token | Expression | Statement,
    end: Token | Expression | Statement
  ): Location {
    // TODO: fix spanning multiple lines
    return new Location(
      begin.location.line,
      Span.between(begin.location.relative, end.location.relative),
      Span.between(begin.location.absolute, end.location.absolute)
    )
  }

  public static readonly unknown = new Location(
    1,
    { begin: 1, end: 1 },
    { begin: 1, end: 1 }
  )
}
