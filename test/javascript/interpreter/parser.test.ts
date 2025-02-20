import {
  ListExpression,
  BinaryExpression,
  FunctionCallExpression,
  GroupingExpression,
  LiteralExpression,
  DictionaryExpression,
  VariableLookupExpression,
  GetElementExpression,
  SetElementExpression,
  UnaryExpression,
  TemplateLiteralExpression,
  TemplatePlaceholderExpression,
  TemplateTextExpression,
  LogicalExpression,
} from '@/interpreter/expression'
import {
  BlockStatement,
  FunctionCallStatement,
  ForeachStatement,
  FunctionStatement,
  IfStatement,
  LogStatement,
  RepeatStatement,
  ReturnStatement,
  SetVariableStatement,
  WhileStatement,
} from '@/interpreter/statement'
import { parse } from '@/interpreter/parser'

describe('comments', () => {
  test('basic text', () => {
    const stmts = parse('// this is a comment')
    expect(stmts).toBeArrayOfSize(0)
  })
  test('text with symbols', () => {
    const stmts = parse('// this (is) a. comme,nt do')
    expect(stmts).toBeArrayOfSize(0)
  })
  test('comment after statement', () => {
    const stmts = parse('set a to 5 // this (is) a. comme,nt do')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    const varStmt = stmts[0] as SetVariableStatement
    expect(varStmt.name.lexeme).toBe('a')
    expect(varStmt.value).toBeInstanceOf(LiteralExpression)
    expect((varStmt.value as LiteralExpression).value).toBe(5)
  })
  test('text with symbols', () => {
    const stmts = parse(`
    // You can use move(), turn_left() and turn_right()
    // Use the functions in the order you want your character
    // to use them to solve them maze. We'll start you off by
    // moving the character one step forward.
    move()
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionCallStatement)
  })
})
describe('literals', () => {
  describe('numbers', () => {
    test('integer', () => {
      const stmts = parse('log 1')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(LiteralExpression)
      const literalExpr = logStmt.expression as LiteralExpression
      expect(literalExpr.value).toBe(1)
    })
    test('floating points', () => {
      const stmts = parse('log 1.5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(LiteralExpression)
      const literalExpr = logStmt.expression as LiteralExpression
      expect(literalExpr.value).toBe(1.5)
    })

    test('negative integer', () => {
      const stmts = parse('log -5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(UnaryExpression)
      const literalExpr = logStmt.expression as UnaryExpression
      expect(literalExpr.operator.lexeme).toBe('-')
      expect((literalExpr.operand as LiteralExpression).value).toBe(5)
    })
    test('negative floating point', () => {
      const stmts = parse('log -1.5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(UnaryExpression)
      const literalExpr = logStmt.expression as UnaryExpression
      expect(literalExpr.operator.lexeme).toBe('-')
      expect((literalExpr.operand as LiteralExpression).value).toBe(1.5)
    })
  })

  test('true', () => {
    const stmts = parse('log true')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(LiteralExpression)
    const literalExpr = logStmt.expression as LiteralExpression
    expect(literalExpr.value).toBe(true)
  })

  test('false', () => {
    const stmts = parse('log false')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(LiteralExpression)
    const literalExpr = logStmt.expression as LiteralExpression
    expect(literalExpr.value).toBe(false)
  })
})

describe('variable', () => {
  test('single-character name', () => {
    const statements = parse('set x to 1')
    expect(statements).toBeArrayOfSize(1)
    expect(statements[0]).toBeInstanceOf(SetVariableStatement)
    const varStatement = statements[0] as SetVariableStatement
    expect(varStatement.name.lexeme).toBe('x')
    const literalExpr = varStatement.value as LiteralExpression
    expect(literalExpr.value).toBe(1)
  })

  test('multi-character name', () => {
    const statements = parse('set fooBar to "abc"')
    expect(statements).toBeArrayOfSize(1)
    expect(statements[0]).toBeInstanceOf(SetVariableStatement)
    const varStatement = statements[0] as SetVariableStatement
    expect(varStatement.name.lexeme).toBe('fooBar')
    const literalExpr = varStatement.value as LiteralExpression
    expect(literalExpr.value).toBe('abc')
  })
})

describe('assignment', () => {
  test('reassignment', () => {
    const statements = parse(`
      set x to 1
      set x to 2
    `)
    expect(statements).toBeArrayOfSize(2)
    expect(statements[1]).toBeInstanceOf(SetVariableStatement)
    const varStatement = statements[1] as SetVariableStatement
    expect(varStatement.name.lexeme).toBe('x')
    const literalExpr = varStatement.value as LiteralExpression
    expect(literalExpr.value).toBe(2)
  })
})

describe('get', () => {
  describe('dictionary', () => {
    test('single field', () => {
      const stmts = parse(`
        set movie to {"title": "The Matrix"}
        set title to movie["title"]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
      const varStmtWithGet = stmts[1] as SetVariableStatement
      expect(varStmtWithGet.value).toBeInstanceOf(GetElementExpression)
      const getExpr = varStmtWithGet.value as GetElementExpression
      expect((getExpr.field as LiteralExpression).value).toBe('title')
      expect(getExpr.obj).toBeInstanceOf(VariableLookupExpression)
      expect((getExpr.obj as VariableLookupExpression).name.lexeme).toBe(
        'movie'
      )
    })

    test.skip('chained', () => {
      const stmts = parse(`
        set movie to {"director": {"name": "Peter Jackson"}}
        set director to movie["director"]["name"]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
      const varStmtWithGet = stmts[1] as SetVariableStatement
      expect(varStmtWithGet.value).toBeInstanceOf(GetElementExpression)
      const getExpr = varStmtWithGet.value as GetElementExpression
      expect(getExpr.field.literal).toBe('name')
      expect(getExpr.obj).toBeInstanceOf(GetElementExpression)
      const nestedGetExpr = getExpr.obj as GetElementExpression
      expect(nestedGetExpr.field.literal).toBe('director')
      expect(nestedGetExpr.obj).toBeInstanceOf(VariableLookupExpression)
      expect((nestedGetExpr.obj as VariableLookupExpression).name.lexeme).toBe(
        'movie'
      )
    })
  })
})

describe('grouping', () => {
  test('non-nested', () => {
    const stmts = parse('log (1 + 2)')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(GroupingExpression)
    const groupingExpr = logStmt.expression as GroupingExpression
    expect(groupingExpr.inner).toBeInstanceOf(BinaryExpression)
    const binaryExpr = groupingExpr.inner as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
  })

  test('nested', () => {
    const stmts = parse('log (1 + (2 - 3))')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(GroupingExpression)
    const groupingExpr = logStmt.expression as GroupingExpression
    expect(groupingExpr.inner).toBeInstanceOf(BinaryExpression)
    const binaryExpr = groupingExpr.inner as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(GroupingExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
    const nestedGroupingExpr = binaryExpr.right as GroupingExpression
    expect(nestedGroupingExpr.inner).toBeInstanceOf(BinaryExpression)
    const nestedBinaryExpr = nestedGroupingExpr.inner as BinaryExpression
    expect(nestedBinaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(nestedBinaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(nestedBinaryExpr.operator.type).toBe('MINUS')
  })
})

describe('binary', () => {
  test('addition', () => {
    const stmts = parse('log 1 + 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = logStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
  })

  test('subtraction', () => {
    const stmts = parse('log 1 - 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = logStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('MINUS')
  })

  test('multiplication', () => {
    const stmts = parse('log 1 * 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = logStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('STAR')
  })

  test('division', () => {
    const stmts = parse('log 1 / 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = logStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('SLASH')
  })

  test('string concatenation', () => {
    const stmts = parse('log "hello" + "world"')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = logStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
  })

  describe('nesting', () => {
    test('numbers', () => {
      const stmts = parse('log 1 + 2 * 3 / 4 - 5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(BinaryExpression)

      const binaryExpr = logStmt.expression as BinaryExpression
      expect(binaryExpr.operator.type).toBe('MINUS')
      expect(binaryExpr.left).toBeInstanceOf(BinaryExpression)
      expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)

      const binaryExprRight = binaryExpr.right as LiteralExpression
      expect(binaryExprRight.value).toBe(5)

      const binaryExprLeft = binaryExpr.left as BinaryExpression
      expect(binaryExprLeft.operator.type).toBe('PLUS')
      expect(binaryExprLeft.left).toBeInstanceOf(LiteralExpression)
      expect(binaryExprLeft.right).toBeInstanceOf(BinaryExpression)

      const binaryExprLeftLeft = binaryExprLeft.left as LiteralExpression
      expect(binaryExprLeftLeft.value).toBe(1)

      const binaryExprLeftRight = binaryExprLeft.right as BinaryExpression
      expect(binaryExprLeftRight.operator.type).toBe('SLASH')
      expect(binaryExprLeftRight.left).toBeInstanceOf(BinaryExpression)
      expect(binaryExprLeftRight.right).toBeInstanceOf(LiteralExpression)

      const binaryExprLeftRightRight =
        binaryExprLeftRight.right as LiteralExpression
      expect(binaryExprLeftRightRight.value).toBe(4)

      const binaryExprLeftRightLeft =
        binaryExprLeftRight.left as BinaryExpression
      expect(binaryExprLeftRightLeft.operator.type).toBe('STAR')
      expect(binaryExprLeftRightLeft.left).toBeInstanceOf(LiteralExpression)
      expect(binaryExprLeftRightLeft.right).toBeInstanceOf(LiteralExpression)
      const binaryExprLeftRightLeftLeft =
        binaryExprLeftRightLeft.left as LiteralExpression
      expect(binaryExprLeftRightLeftLeft.value).toBe(2)
      const binaryExprLeftRightLeftRight =
        binaryExprLeftRightLeft.right as LiteralExpression
      expect(binaryExprLeftRightLeftRight.value).toBe(3)
    })

    test('string concatenation', () => {
      const stmts = parse('log "hello" + "world" + "!"')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(BinaryExpression)
      const binaryExpr = logStmt.expression as BinaryExpression
      expect(binaryExpr.operator.type).toBe('PLUS')
      expect(binaryExpr.left).toBeInstanceOf(BinaryExpression)
      expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)

      const binaryExprRight = binaryExpr.right as LiteralExpression
      expect(binaryExprRight.value).toBe('!')

      const binaryExprLeft = binaryExpr.left as BinaryExpression
      expect(binaryExprLeft.left).toBeInstanceOf(LiteralExpression)
      expect(binaryExprLeft.right).toBeInstanceOf(LiteralExpression)

      const binaryExprLeftLeft = binaryExprLeft.left as LiteralExpression
      expect(binaryExprLeftLeft.value).toBe('hello')

      const binaryExprLeftRight = binaryExprLeft.right as LiteralExpression
      expect(binaryExprLeftRight.value).toBe('world')
    })
  })
})

describe('logical', () => {
  test('and', () => {
    const stmts = parse('log true and false')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(LogicalExpression)
    const logicalExpr = logStmt.expression as LogicalExpression
    expect(logicalExpr.left).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.right).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.operator.type).toBe('AND')
  })

  test('or', () => {
    const stmts = parse('log true or false')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(LogicalExpression)
    const logicalExpr = logStmt.expression as LogicalExpression
    expect(logicalExpr.left).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.right).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.operator.type).toBe('OR')
  })
})

describe('if', () => {
  test('single boolean', () => {
    const stmts = parse(`
      if true do
        set x to 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
    expect(expStmt.elseBranch).toBeNil()
  })
  test('without else', () => {
    const stmts = parse(`
      if something is true do
        set x to 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(BinaryExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
    expect(expStmt.elseBranch).toBeNil()
  })

  test('with else', () => {
    const stmts = parse(`
      if something is true do
        set x to 1
      else do
        set x to 2
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(BinaryExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
    expect(expStmt.elseBranch).toBeInstanceOf(BlockStatement)
    const elseStmt = expStmt.elseBranch as BlockStatement
    expect(elseStmt.statements).toBeArrayOfSize(1)
    expect(elseStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
  })

  test('nested', () => {
    const stmts = parse(`
      if something is true do
        set x to 1
      else if something is false do
        set x to 2
      else do
        set x to 3
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(BinaryExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
    expect(expStmt.elseBranch).toBeInstanceOf(IfStatement)
    const elseIfStmt = expStmt.elseBranch as IfStatement
    expect(elseIfStmt.condition).toBeInstanceOf(BinaryExpression)
    expect(elseIfStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const elseIfStmtThenBlock = elseIfStmt.thenBranch as BlockStatement
    expect(elseIfStmtThenBlock.statements).toBeArrayOfSize(1)
    expect(elseIfStmtThenBlock.statements[0]).toBeInstanceOf(
      SetVariableStatement
    )
    expect(elseIfStmt.elseBranch).toBeInstanceOf(BlockStatement)
    const elseIfStmtElseBlock = elseIfStmt.elseBranch as BlockStatement
    expect(elseIfStmtElseBlock.statements).toBeArrayOfSize(1)
    expect(elseIfStmtElseBlock.statements[0]).toBeInstanceOf(
      SetVariableStatement
    )
  })
})

describe('repeat', () => {
  test('with number literal', () => {
    const stmts = parse(`
      repeat 3 times do
        set x to 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(RepeatStatement)
    const expStmt = stmts[0] as RepeatStatement
    expect(expStmt.count).toBeInstanceOf(LiteralExpression)
    expect(expStmt.body).toBeArrayOfSize(1)
    expect(expStmt.body[0]).toBeInstanceOf(SetVariableStatement)
  })
})

describe('while', () => {
  test.skip('with single statement', () => {
    const stmts = parse(`
      while something is true do
        set x to 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(WhileStatement)
    const expStmt = stmts[0] as WhileStatement
    expect(expStmt.condition).toBeInstanceOf(BinaryExpression)
    expect(expStmt.body).toBeArrayOfSize(1)
    expect(expStmt.body[0]).toBeInstanceOf(SetVariableStatement)
  })
})

describe('block', () => {
  test('non-nested', () => {
    const stmts = parse(`
      do
        set x to 1
        set y to 2
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(BlockStatement)
    const blockStmt = stmts[0] as BlockStatement
    expect(blockStmt.statements).toBeArrayOfSize(2)
    expect(blockStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
    expect(blockStmt.statements[1]).toBeInstanceOf(SetVariableStatement)
  })

  test('nested', () => {
    const stmts = parse(`
      do
        set x to 1
        do
          set y to 2
        end
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(BlockStatement)
    const blockStmt = stmts[0] as BlockStatement
    expect(blockStmt.statements).toBeArrayOfSize(2)
    expect(blockStmt.statements[0]).toBeInstanceOf(SetVariableStatement)
    expect(blockStmt.statements[1]).toBeInstanceOf(BlockStatement)
  })
})

describe('white space', () => {
  test('skip over empty lines', () => {
    const stmts = parse(`
      set a to 19

      \t\t\t
      set x to true

      set y to false
      \t

    `)
    expect(stmts).toBeArrayOfSize(3)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
    expect(stmts[2]).toBeInstanceOf(SetVariableStatement)
  })
})

describe('location', () => {
  describe('statement', () => {
    test('LogStatement', () => {
      const statements = parse('log 123')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(LogStatement)
      const logStatement = statements[0] as LogStatement
      expect(logStatement.location.line).toBe(1)
      expect(logStatement.location.relative.begin).toBe(1)
      expect(logStatement.location.relative.end).toBe(8)
      expect(logStatement.location.absolute.begin).toBe(1)
      expect(logStatement.location.absolute.end).toBe(8)
    })
  })

  describe('expression', () => {
    test('literal', () => {
      const statements = parse('log 123')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(LogStatement)
      const callStatement = statements[0] as LogStatement
      const expression = callStatement.expression
      expect(expression).toBeInstanceOf(LiteralExpression)

      expect(expression.location.line).toBe(1)
      expect(expression.location.relative.begin).toBe(5)
      expect(expression.location.relative.end).toBe(8)
      expect(expression.location.absolute.begin).toBe(5)
      expect(expression.location.absolute.end).toBe(8)
    })

    test('variable', () => {
      const statements = parse('log foo')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(LogStatement)
      const logStatement = statements[0] as LogStatement
      const expression = logStatement.expression
      expect(expression).toBeInstanceOf(VariableLookupExpression)
      expect(expression.location.line).toBe(1)
      expect(expression.location.relative.begin).toBe(5)
      expect(expression.location.relative.end).toBe(8)
      expect(expression.location.absolute.begin).toBe(5)
      expect(expression.location.absolute.end).toBe(8)
    })

    test('call', () => {
      const statements = parse('move(7)')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(FunctionCallStatement)
      const callStatement = statements[0] as FunctionCallStatement
      const expression = callStatement.expression
      expect(expression).toBeInstanceOf(FunctionCallExpression)
      expect(expression.location.line).toBe(1)
      expect(expression.location.relative.begin).toBe(1)
      expect(expression.location.relative.end).toBe(8)
      expect(expression.location.absolute.begin).toBe(1)
      expect(expression.location.absolute.end).toBe(8)
    })
  })
})

describe('lists', () => {})
