type ObjectType = 'number' | 'string' | 'boolean' | 'list' | 'dictionary'

export class JikiObject {
  constructor(public readonly type: ObjectType, public readonly value: any) {}
}

export class Number extends JikiObject {
  constructor(value: number) {
    super('number', value)
  }
}

export class String extends JikiObject {
  constructor(value: string) {
    super('string', value)
  }
}

export class Boolean extends JikiObject {
  constructor(value: boolean) {
    super('boolean', value)
  }
}

export class List extends JikiObject {
  constructor(value: any[]) {
    super('list', value)
  }
}

export class Dictionary extends JikiObject {
  constructor(value: Record<string, any>) {
    super('dictionary', value)
  }
}
