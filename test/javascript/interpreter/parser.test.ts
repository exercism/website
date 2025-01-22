import {
  ArrayExpression,
  BinaryExpression,
  CallExpression,
  GroupingExpression,
  LiteralExpression,
  DictionaryExpression,
  VariableExpression,
  GetExpression,
  SetExpression,
  UnaryExpression,
  TemplateLiteralExpression,
  TemplatePlaceholderExpression,
  TemplateTextExpression,
  LogicalExpression,
} from '@/interpreter/expression'
import {
  BlockStatement,
  ExpressionStatement,
  ForeachStatement,
  FunctionStatement,
  IfStatement,
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
    expect(varStmt.initializer).toBeInstanceOf(LiteralExpression)
    expect((varStmt.initializer as LiteralExpression).value).toBe(5)
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
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
  })
})
describe('literals', () => {
  describe('numbers', () => {
    test('integer', () => {
      const stmts = parse('1')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(LiteralExpression)
      const literalExpr = exprStmt.expression as LiteralExpression
      expect(literalExpr.value).toBe(1)
    })
    test('floating points', () => {
      const stmts = parse('1.5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(LiteralExpression)
      const literalExpr = exprStmt.expression as LiteralExpression
      expect(literalExpr.value).toBe(1.5)
    })

    test('negative integer', () => {
      const stmts = parse('-5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(UnaryExpression)
      const literalExpr = exprStmt.expression as UnaryExpression
      expect(literalExpr.operator.lexeme).toBe('-')
      expect((literalExpr.operand as LiteralExpression).value).toBe(5)
    })
    test('negative floating point', () => {
      const stmts = parse('-1.5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(UnaryExpression)
      const literalExpr = exprStmt.expression as UnaryExpression
      expect(literalExpr.operator.lexeme).toBe('-')
      expect((literalExpr.operand as LiteralExpression).value).toBe(1.5)
    })
  })

  test('string', () => {
    const stmts = parse('"nice"')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(LiteralExpression)
    const literalExpr = exprStmt.expression as LiteralExpression
    expect(literalExpr.value).toBe('nice')
  })

  test('true', () => {
    const stmts = parse('true')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(LiteralExpression)
    const literalExpr = exprStmt.expression as LiteralExpression
    expect(literalExpr.value).toBe(true)
  })

  test('false', () => {
    const stmts = parse('false')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(LiteralExpression)
    const literalExpr = exprStmt.expression as LiteralExpression
    expect(literalExpr.value).toBe(false)
  })

  test('null', () => {
    const stmts = parse('null')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(LiteralExpression)
    const literalExpr = exprStmt.expression as LiteralExpression
    expect(literalExpr.value).toBeNull()
  })
})

describe('array', () => {
  test('empty', () => {
    const stmts = parse('[]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(ArrayExpression)
    const arrayExpr = exprStmt.expression as ArrayExpression
    expect(arrayExpr.elements).toBeEmpty()
  })

  test('single element', () => {
    const stmts = parse('[1]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(ArrayExpression)
    const arrayExpr = exprStmt.expression as ArrayExpression
    expect(arrayExpr.elements).toBeArrayOfSize(1)
    expect(arrayExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    const firstElemExpr = arrayExpr.elements[0] as LiteralExpression
    expect(firstElemExpr.value).toBe(1)
  })

  test('multiple elements', () => {
    const stmts = parse('[1,2,3]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(ArrayExpression)
    const arrayExpr = exprStmt.expression as ArrayExpression
    expect(arrayExpr.elements).toBeArrayOfSize(3)
    expect(arrayExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect(arrayExpr.elements[1]).toBeInstanceOf(LiteralExpression)
    expect(arrayExpr.elements[2]).toBeInstanceOf(LiteralExpression)
    expect((arrayExpr.elements[0] as LiteralExpression).value).toBe(1)
    expect((arrayExpr.elements[1] as LiteralExpression).value).toBe(2)
    expect((arrayExpr.elements[2] as LiteralExpression).value).toBe(3)
  })

  test('nested', () => {
    const stmts = parse('[1,[2,[3]]]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(ArrayExpression)
    const arrayExpr = exprStmt.expression as ArrayExpression
    expect(arrayExpr.elements).toBeArrayOfSize(2)
    expect(arrayExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect((arrayExpr.elements[0] as LiteralExpression).value).toBe(1)
    expect(arrayExpr.elements[1]).toBeInstanceOf(ArrayExpression)
    const nestedExpr = arrayExpr.elements[1] as ArrayExpression
    expect(nestedExpr.elements).toBeArrayOfSize(2)
    expect(nestedExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect((nestedExpr.elements[0] as LiteralExpression).value).toBe(2)
    expect(nestedExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    const nestedNestedExpr = nestedExpr.elements[1] as ArrayExpression
    expect(nestedNestedExpr.elements).toBeArrayOfSize(1)
    expect(nestedNestedExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect((nestedNestedExpr.elements[0] as LiteralExpression).value).toBe(3)
  })

  test('expressions', () => {
    const stmts = parse('[-1,2*2,3+3]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(ArrayExpression)
    const arrayExpr = exprStmt.expression as ArrayExpression
    expect(arrayExpr.elements).toBeArrayOfSize(3)
    expect(arrayExpr.elements[0]).toBeInstanceOf(UnaryExpression)
    expect(arrayExpr.elements[1]).toBeInstanceOf(BinaryExpression)
    expect(arrayExpr.elements[2]).toBeInstanceOf(BinaryExpression)
  })
})

describe('dictionary', () => {
  test('empty', () => {
    const stmts = parse('set empty to {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    const varStmt = stmts[0] as SetVariableStatement
    expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
    const mapExpr = varStmt.initializer as DictionaryExpression
    expect(mapExpr.elements).toBeEmpty()
  })

  test('single element', () => {
    const stmts = parse('set movie to {"title": "Jurassic Park"}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    const varStmt = stmts[0] as SetVariableStatement
    expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
    const mapExpr = varStmt.initializer as DictionaryExpression
    expect(mapExpr.elements.size).toBe(1)
    expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
    expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
      'Jurassic Park'
    )
  })

  test('multiple elements', () => {
    const stmts = parse('set movie to {"title": "Jurassic Park", "year": 1993}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    const varStmt = stmts[0] as SetVariableStatement
    expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
    const mapExpr = varStmt.initializer as DictionaryExpression
    expect(mapExpr.elements.size).toBe(2)
    expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
    expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
      'Jurassic Park'
    )
    expect(mapExpr.elements.get('year')).toBeInstanceOf(LiteralExpression)
    expect((mapExpr.elements.get('year') as LiteralExpression).value).toBe(1993)
  })

  test('nested', () => {
    const stmts = parse(
      'set movie to {"title": "Jurassic Park", "director": { "name": "Steven Spielberg" } }'
    )
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    const varStmt = stmts[0] as SetVariableStatement
    expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
    const mapExpr = varStmt.initializer as DictionaryExpression
    expect(mapExpr.elements.size).toBe(2)
    expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
    expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
      'Jurassic Park'
    )
    expect(mapExpr.elements.get('director')).toBeInstanceOf(
      DictionaryExpression
    )
    const nestedMapExpr = mapExpr.elements.get(
      'director'
    ) as DictionaryExpression
    expect(nestedMapExpr.elements.size).toBe(1)
    expect(nestedMapExpr.elements.get('name')).toBeInstanceOf(LiteralExpression)
    expect(
      (nestedMapExpr.elements.get('name') as LiteralExpression).value
    ).toBe('Steven Spielberg')
  })
})

describe('variable', () => {
  test('single-character name', () => {
    const statements = parse('set x to 1')
    expect(statements).toBeArrayOfSize(1)
    expect(statements[0]).toBeInstanceOf(SetVariableStatement)
    const varStatement = statements[0] as SetVariableStatement
    expect(varStatement.name.lexeme).toBe('x')
    const literalExpr = varStatement.initializer as LiteralExpression
    expect(literalExpr.value).toBe(1)
  })

  test('multi-character name', () => {
    const statements = parse('set fooBar to "abc"')
    expect(statements).toBeArrayOfSize(1)
    expect(statements[0]).toBeInstanceOf(SetVariableStatement)
    const varStatement = statements[0] as SetVariableStatement
    expect(varStatement.name.lexeme).toBe('fooBar')
    const literalExpr = varStatement.initializer as LiteralExpression
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
    const literalExpr = varStatement.initializer as LiteralExpression
    expect(literalExpr.value).toBe(2)
  })
})

describe('call', () => {
  test('without arguments', () => {
    const stmts = parse('move()')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const expStmt = stmts[0] as ExpressionStatement
    expect(expStmt.expression).toBeInstanceOf(CallExpression)
    const callExpr = expStmt.expression as CallExpression
    expect(callExpr.args).toBeEmpty()
  })

  test('single argument', () => {
    const stmts = parse('turn("left")')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(CallExpression)
    const callExpr = exprStmt.expression as CallExpression
    expect(callExpr.args).toBeArrayOfSize(1)
    expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
  })

  test('chained', () => {
    const stmts = parse('turn("left")("right")')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(CallExpression)
    const callExpr = exprStmt.expression as CallExpression
    expect(callExpr.args).toBeArrayOfSize(1)
    expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
    expect(callExpr.callee).toBeInstanceOf(CallExpression)
    const nestedCallExpr = callExpr.callee as CallExpression
    expect(nestedCallExpr.args).toBeArrayOfSize(1)
    expect(nestedCallExpr.args[0]).toBeInstanceOf(LiteralExpression)
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
      expect(varStmtWithGet.initializer).toBeInstanceOf(GetExpression)
      const getExpr = varStmtWithGet.initializer as GetExpression
      expect(getExpr.field.literal).toBe('title')
      expect(getExpr.obj).toBeInstanceOf(VariableExpression)
      expect((getExpr.obj as VariableExpression).name.lexeme).toBe('movie')
    })

    test('chained', () => {
      const stmts = parse(`
        set movie to {"director": {"name": "Peter Jackson"}}
        set director to movie["director"]["name"]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
      const varStmtWithGet = stmts[1] as SetVariableStatement
      expect(varStmtWithGet.initializer).toBeInstanceOf(GetExpression)
      const getExpr = varStmtWithGet.initializer as GetExpression
      expect(getExpr.field.literal).toBe('name')
      expect(getExpr.obj).toBeInstanceOf(GetExpression)
      const nestedGetExpr = getExpr.obj as GetExpression
      expect(nestedGetExpr.field.literal).toBe('director')
      expect(nestedGetExpr.obj).toBeInstanceOf(VariableExpression)
      expect((nestedGetExpr.obj as VariableExpression).name.lexeme).toBe(
        'movie'
      )
    })
  })

  describe('array', () => {
    test('single field', () => {
      const stmts = parse(`
        set scores to [7, 3, 10]
        set latest to scores[2]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
      const varStmtWithGet = stmts[1] as SetVariableStatement
      expect(varStmtWithGet.initializer).toBeInstanceOf(GetExpression)
      const getExpr = varStmtWithGet.initializer as GetExpression
      expect(getExpr.field.literal).toBe(2)
      expect(getExpr.obj).toBeInstanceOf(VariableExpression)
      expect((getExpr.obj as VariableExpression).name.lexeme).toBe('scores')
    })

    test('chained', () => {
      const stmts = parse(`
        set scoreMinMax to [[3, 7], [1, 6]]
        set secondMin to scoreMinMax[1][0]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
      const varStmtWithGet = stmts[1] as SetVariableStatement
      expect(varStmtWithGet.initializer).toBeInstanceOf(GetExpression)
      const getExpr = varStmtWithGet.initializer as GetExpression
      expect(getExpr.field.literal).toBe(0)
      expect(getExpr.obj).toBeInstanceOf(GetExpression)
      const nestedGetExpr = getExpr.obj as GetExpression
      expect(nestedGetExpr.field.literal).toBe(1)
      expect(nestedGetExpr.obj).toBeInstanceOf(VariableExpression)
      expect((nestedGetExpr.obj as VariableExpression).name.lexeme).toBe(
        'scoreMinMax'
      )
    })
  })
})

describe('set', () => {
  describe('dictionary', () => {
    test('single field', () => {
      const stmts = parse(`
        set movie to {"title": "The Matrix"}
        set movie["title"] to "Gladiator"
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[1] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(SetExpression)
      const setExpr = exprStmt.expression as SetExpression
      expect(setExpr.field.literal).toBe('title')
      expect(setExpr.obj).toBeInstanceOf(VariableExpression)
      expect((setExpr.obj as VariableExpression).name.lexeme).toBe('movie')
    })

    test('chained', () => {
      const stmts = parse(`
        set movie to {"director": {"name": "Peter Jackson"}}
        set movie["director"]["name"] to "James Cameron"
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[1] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(SetExpression)
      const setExpr = exprStmt.expression as SetExpression
      expect(setExpr.value).toBeInstanceOf(LiteralExpression)
      expect((setExpr.value as LiteralExpression).value).toBe('James Cameron')
      expect(setExpr.field.literal).toBe('name')
      expect(setExpr.obj).toBeInstanceOf(GetExpression)
      const getExpr = setExpr.obj as GetExpression
      expect(getExpr.obj).toBeInstanceOf(VariableExpression)
      expect((getExpr.obj as VariableExpression).name.lexeme).toBe('movie')
      expect(getExpr.field.literal).toBe('director')
    })
  })

  // TODO: add set on arrays
})

describe('template literal', () => {
  test('empty', () => {
    const stmts = parse('``')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(TemplateLiteralExpression)
    const templateExpr = exprStmt.expression as TemplateLiteralExpression
    expect(templateExpr.parts).toBeEmpty()
  })

  test('no placeholders', () => {
    const stmts = parse('`hello there`')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(TemplateLiteralExpression)
    const templateExpr = exprStmt.expression as TemplateLiteralExpression
    expect(templateExpr.parts).toBeArrayOfSize(1)
    expect(templateExpr.parts[0]).toBeInstanceOf(TemplateTextExpression)
    const textExpr = templateExpr.parts[0] as TemplateTextExpression
    expect(textExpr.text.literal).toBe('hello there')
  })

  test('placeholders', () => {
    const stmts = parse('`sum of ${2} + ${1+3*5} = ${2+(1+4*5)}`')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(TemplateLiteralExpression)
    const templateExpr = exprStmt.expression as TemplateLiteralExpression
    expect(templateExpr.parts).toBeArrayOfSize(6)
    expect(templateExpr.parts[0]).toBeInstanceOf(TemplateTextExpression)
    expect(templateExpr.parts[1]).toBeInstanceOf(TemplatePlaceholderExpression)
    expect(templateExpr.parts[2]).toBeInstanceOf(TemplateTextExpression)
    expect(templateExpr.parts[3]).toBeInstanceOf(TemplatePlaceholderExpression)
    expect(templateExpr.parts[4]).toBeInstanceOf(TemplateTextExpression)
    expect(templateExpr.parts[5]).toBeInstanceOf(TemplatePlaceholderExpression)
    const part0Expr = templateExpr.parts[0] as TemplateTextExpression
    expect(part0Expr.text.lexeme).toBe('sum of ')
    const part1Expr = templateExpr.parts[1] as TemplatePlaceholderExpression
    expect(part1Expr.inner).toBeInstanceOf(LiteralExpression)
    const part2Expr = templateExpr.parts[2] as TemplateTextExpression
    expect(part2Expr.text.lexeme).toBe(' + ')
    const part3Expr = templateExpr.parts[3] as TemplatePlaceholderExpression
    expect(part3Expr.inner).toBeInstanceOf(BinaryExpression)
    const part4Expr = templateExpr.parts[4] as TemplateTextExpression
    expect(part4Expr.text.lexeme).toBe(' = ')
    const part5Expr = templateExpr.parts[5] as TemplatePlaceholderExpression
    expect(part5Expr.inner).toBeInstanceOf(BinaryExpression)
  })
})

describe('grouping', () => {
  test('non-nested', () => {
    const stmts = parse('(1 + 2)')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(GroupingExpression)
    const groupingExpr = exprStmt.expression as GroupingExpression
    expect(groupingExpr.inner).toBeInstanceOf(BinaryExpression)
    const binaryExpr = groupingExpr.inner as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
  })

  test('nested', () => {
    const stmts = parse('(1 + (2 - 3))')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(GroupingExpression)
    const groupingExpr = exprStmt.expression as GroupingExpression
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
    const stmts = parse('1 + 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = exprStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
  })

  test('subtraction', () => {
    const stmts = parse('1 - 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = exprStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('MINUS')
  })

  test('multiplication', () => {
    const stmts = parse('1 * 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = exprStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('STAR')
  })

  test('division', () => {
    const stmts = parse('1 / 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = exprStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('SLASH')
  })

  test('string concatenation', () => {
    const stmts = parse('"hello" + "world"')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)
    const binaryExpr = exprStmt.expression as BinaryExpression
    expect(binaryExpr.left).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.right).toBeInstanceOf(LiteralExpression)
    expect(binaryExpr.operator.type).toBe('PLUS')
  })

  describe('nesting', () => {
    test('numbers', () => {
      const stmts = parse('1 + 2 * 3 / 4 - 5')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)

      const binaryExpr = exprStmt.expression as BinaryExpression
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
      const stmts = parse('"hello" + "world" + "!"')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(BinaryExpression)
      const binaryExpr = exprStmt.expression as BinaryExpression
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
    const stmts = parse('true and false')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(LogicalExpression)
    const logicalExpr = exprStmt.expression as LogicalExpression
    expect(logicalExpr.left).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.right).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.operator.type).toBe('AND')
  })

  test('or', () => {
    const stmts = parse('true or false')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const exprStmt = stmts[0] as ExpressionStatement
    expect(exprStmt.expression).toBeInstanceOf(LogicalExpression)
    const logicalExpr = exprStmt.expression as LogicalExpression
    expect(logicalExpr.left).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.right).toBeInstanceOf(LiteralExpression)
    expect(logicalExpr.operator.type).toBe('OR')
  })
})

describe('if', () => {
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
  test('with single statement', () => {
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

describe('foreach', () => {
  test('with single statement in body', () => {
    // TODO: Get rid of let
    const stmts = parse(`
      foreach elem in [] do
        set x to elem + 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ForeachStatement)
    const foreachStmt = stmts[0] as ForeachStatement
    expect(foreachStmt.elementName.lexeme).toBe('elem')
    expect(foreachStmt.iterable).toBeInstanceOf(ArrayExpression)
    expect(foreachStmt.body).toBeArrayOfSize(1)
    expect(foreachStmt.body[0]).toBeInstanceOf(SetVariableStatement)
  })

  test('with multiple statements in body', () => {
    const stmts = parse(`
      foreach elem in [] do
        set x to elem + 1
        set y to elem - 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ForeachStatement)
    const foreachStmt = stmts[0] as ForeachStatement
    expect(foreachStmt.elementName.lexeme).toBe('elem')
    expect(foreachStmt.iterable).toBeInstanceOf(ArrayExpression)
    expect(foreachStmt.body).toBeArrayOfSize(2)
    expect(foreachStmt.body[0]).toBeInstanceOf(SetVariableStatement)
    expect(foreachStmt.body[1]).toBeInstanceOf(SetVariableStatement)
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

describe('function', () => {
  test('without parameters', () => {
    const stmts = parse(`
      function move do
        return 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionStatement)
    const functionStmt = stmts[0] as FunctionStatement
    expect(functionStmt.name.lexeme).toBe('move')
    expect(functionStmt.parameters).toBeEmpty()
    expect(functionStmt.body).toBeArrayOfSize(1)
    expect(functionStmt.body[0]).toBeInstanceOf(ReturnStatement)
  })

  test('with parameters', () => {
    const stmts = parse(`
      function move with x, y do
        return x + y
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionStatement)
    const functionStmt = stmts[0] as FunctionStatement
    expect(functionStmt.name.lexeme).toBe('move')
    expect(functionStmt.parameters).toBeArrayOfSize(2)
    expect(functionStmt.parameters[0].name.lexeme).toBe('x')
    expect(functionStmt.parameters[1].name.lexeme).toBe('y')
    expect(functionStmt.body).toBeArrayOfSize(1)
    expect(functionStmt.body[0]).toBeInstanceOf(ReturnStatement)
  })
})

describe('return', () => {
  test('without argument', () => {
    const stmts = parse('return')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ReturnStatement)
    const returnStmt = stmts[0] as ReturnStatement
    expect(returnStmt.value).toBeNull()
  })

  describe('with argument', () => {
    test('number', () => {
      const stmts = parse('return 2')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ReturnStatement)
      const returnStmt = stmts[0] as ReturnStatement
      expect(returnStmt.value).toBeInstanceOf(LiteralExpression)
      const literalExpr = returnStmt.value as LiteralExpression
      expect(literalExpr.value).toBe(2)
    })

    test('string', () => {
      const stmts = parse('return "hello there!"')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ReturnStatement)
      const returnStmt = stmts[0] as ReturnStatement
      expect(returnStmt.value).toBeInstanceOf(LiteralExpression)
      const literalExpr = returnStmt.value as LiteralExpression
      expect(literalExpr.value).toBe('hello there!')
    })
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
    test('expression', () => {
      const statements = parse('123')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(ExpressionStatement)
      const expressionStatement = statements[0] as ExpressionStatement
      expect(expressionStatement.location.line).toBe(1)
      expect(expressionStatement.location.relative.begin).toBe(1)
      expect(expressionStatement.location.relative.end).toBe(4)
      expect(expressionStatement.location.absolute.begin).toBe(1)
      expect(expressionStatement.location.absolute.end).toBe(4)
    })

    test('variable', () => {
      const statements = parse('set x to 1')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(SetVariableStatement)
      const expressionStatement = statements[0] as SetVariableStatement
      expect(expressionStatement.location.line).toBe(1)
      expect(expressionStatement.location.relative.begin).toBe(1)
      expect(expressionStatement.location.relative.end).toBe(11)
      expect(expressionStatement.location.absolute.begin).toBe(1)
      expect(expressionStatement.location.absolute.end).toBe(11)
    })
  })

  describe('expression', () => {
    test('literal', () => {
      const statements = parse('123')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(ExpressionStatement)
      const expressionStatement = statements[0] as ExpressionStatement
      const expression = expressionStatement.expression
      expect(expression).toBeInstanceOf(LiteralExpression)

      expect(expression.location.line).toBe(1)
      expect(expression.location.relative.begin).toBe(1)
      expect(expression.location.relative.end).toBe(4)
      expect(expression.location.absolute.begin).toBe(1)
      expect(expression.location.absolute.end).toBe(4)
    })

    test('variable', () => {
      const statements = parse('foo')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(ExpressionStatement)
      const expressionStatement = statements[0] as ExpressionStatement
      const expression = expressionStatement.expression
      expect(expression).toBeInstanceOf(VariableExpression)
      expect(expression.location.line).toBe(1)
      expect(expression.location.relative.begin).toBe(1)
      expect(expression.location.relative.end).toBe(4)
      expect(expression.location.absolute.begin).toBe(1)
      expect(expression.location.absolute.end).toBe(4)
    })

    test('call', () => {
      const statements = parse('move(7)')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(ExpressionStatement)
      const expressionStatement = statements[0] as ExpressionStatement
      const expression = expressionStatement.expression
      expect(expression).toBeInstanceOf(CallExpression)
      expect(expression.location.line).toBe(1)
      expect(expression.location.relative.begin).toBe(1)
      expect(expression.location.relative.end).toBe(8)
      expect(expression.location.absolute.begin).toBe(1)
      expect(expression.location.absolute.end).toBe(8)
    })
  })
})
