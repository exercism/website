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
  AssignExpression,
  UpdateExpression,
  TernaryExpression,
} from '@/interpreter/expression'
import {
  BlockStatement,
  ConstantStatement,
  DoWhileStatement,
  ExpressionStatement,
  FunctionStatement,
  IfStatement,
  ReturnStatement,
  VariableStatement,
  WhileStatement,
} from '@/interpreter/statement'
import { parse } from '@/interpreter/languages/javascript/parser'

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
    const stmts = parse('let empty = {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(VariableStatement)
    const varStmt = stmts[0] as VariableStatement
    expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
    const mapExpr = varStmt.initializer as DictionaryExpression
    expect(mapExpr.elements).toBeEmpty()
  })

  test('single element', () => {
    const stmts = parse('let movie = {"title": "Jurassic Park"}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(VariableStatement)
    const varStmt = stmts[0] as VariableStatement
    expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
    const mapExpr = varStmt.initializer as DictionaryExpression
    expect(mapExpr.elements.size).toBe(1)
    expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
    expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
      'Jurassic Park'
    )
  })

  test('multiple elements', () => {
    const stmts = parse('let movie = {"title": "Jurassic Park", "year": 1993}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(VariableStatement)
    const varStmt = stmts[0] as VariableStatement
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
      'let movie = {"title": "Jurassic Park", "director": { "name": "Steven Spielberg" } }'
    )
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(VariableStatement)
    const varStmt = stmts[0] as VariableStatement
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
    const statements = parse('let x = 1')
    expect(statements).toBeArrayOfSize(1)
    expect(statements[0]).toBeInstanceOf(VariableStatement)
    const varStatement = statements[0] as VariableStatement
    expect(varStatement.name.lexeme).toBe('x')
    const literalExpr = varStatement.initializer as LiteralExpression
    expect(literalExpr.value).toBe(1)
  })

  test('multi-character name', () => {
    const statements = parse('let fooBar = "abc"')
    expect(statements).toBeArrayOfSize(1)
    expect(statements[0]).toBeInstanceOf(VariableStatement)
    const varStatement = statements[0] as VariableStatement
    expect(varStatement.name.lexeme).toBe('fooBar')
    const literalExpr = varStatement.initializer as LiteralExpression
    expect(literalExpr.value).toBe('abc')
  })
})

describe('assignment', () => {
  test('regular', () => {
    const statements = parse(`
      let x = 1
      x = 2
    `)
    expect(statements).toBeArrayOfSize(2)
    expect(statements[1]).toBeInstanceOf(ExpressionStatement)
    const exprStatement = statements[1] as ExpressionStatement
    expect(exprStatement.expression).toBeInstanceOf(AssignExpression)
    const assignExpr = exprStatement.expression as AssignExpression
    expect(assignExpr.name.lexeme).toBe('x')
    expect(assignExpr.operator.type).toBe('EQUAL')
    expect(assignExpr.value).toBeInstanceOf(LiteralExpression)
    const literalExpr = assignExpr.value as LiteralExpression
    expect(literalExpr.value).toBe(2)
  })

  describe('compound', () => {
    test('plus', () => {
      const statements = parse(`
        let x = 1
        x += 2
      `)
      expect(statements).toBeArrayOfSize(2)
      expect(statements[1]).toBeInstanceOf(ExpressionStatement)
      const exprStatement = statements[1] as ExpressionStatement
      expect(exprStatement.expression).toBeInstanceOf(AssignExpression)
      const assignExpr = exprStatement.expression as AssignExpression
      expect(assignExpr.name.lexeme).toBe('x')
      expect(assignExpr.operator.type).toBe('PLUS_EQUAL')
      expect(assignExpr.value).toBeInstanceOf(LiteralExpression)
      const literalExpr = assignExpr.value as LiteralExpression
      expect(literalExpr.value).toBe(2)
    })

    test('minus', () => {
      const statements = parse(`
        let x = 1
        x -= 2
      `)
      expect(statements).toBeArrayOfSize(2)
      expect(statements[1]).toBeInstanceOf(ExpressionStatement)
      const exprStatement = statements[1] as ExpressionStatement
      expect(exprStatement.expression).toBeInstanceOf(AssignExpression)
      const assignExpr = exprStatement.expression as AssignExpression
      expect(assignExpr.name.lexeme).toBe('x')
      expect(assignExpr.operator.type).toBe('MINUS_EQUAL')
      expect(assignExpr.value).toBeInstanceOf(LiteralExpression)
      const literalExpr = assignExpr.value as LiteralExpression
      expect(literalExpr.value).toBe(2)
    })

    test('multiply', () => {
      const statements = parse(`
        let x = 1
        x *= 2
      `)
      expect(statements).toBeArrayOfSize(2)
      expect(statements[1]).toBeInstanceOf(ExpressionStatement)
      const exprStatement = statements[1] as ExpressionStatement
      expect(exprStatement.expression).toBeInstanceOf(AssignExpression)
      const assignExpr = exprStatement.expression as AssignExpression
      expect(assignExpr.name.lexeme).toBe('x')
      expect(assignExpr.operator.type).toBe('STAR_EQUAL')
      expect(assignExpr.value).toBeInstanceOf(LiteralExpression)
      const literalExpr = assignExpr.value as LiteralExpression
      expect(literalExpr.value).toBe(2)
    })

    test('divide', () => {
      const statements = parse(`
        let x = 1
        x /= 2
      `)
      expect(statements).toBeArrayOfSize(2)
      expect(statements[1]).toBeInstanceOf(ExpressionStatement)
      const exprStatement = statements[1] as ExpressionStatement
      expect(exprStatement.expression).toBeInstanceOf(AssignExpression)
      const assignExpr = exprStatement.expression as AssignExpression
      expect(assignExpr.name.lexeme).toBe('x')
      expect(assignExpr.operator.type).toBe('SLASH_EQUAL')
      expect(assignExpr.value).toBeInstanceOf(LiteralExpression)
      const literalExpr = assignExpr.value as LiteralExpression
      expect(literalExpr.value).toBe(2)
    })
  })
})

describe('increment', () => {
  test('variable', () => {
    const statements = parse(`
      let x = 1
      x++
    `)
    expect(statements).toBeArrayOfSize(2)
    expect(statements[1]).toBeInstanceOf(ExpressionStatement)
    const exprStatement = statements[1] as ExpressionStatement
    expect(exprStatement.expression).toBeInstanceOf(UpdateExpression)
    const incrementExpr = exprStatement.expression as UpdateExpression
    expect(incrementExpr.operator.type).toBe('PLUS_PLUS')
    expect(incrementExpr.operand).toBeInstanceOf(VariableExpression)
    const variableExpr = incrementExpr.operand as VariableExpression
    expect(variableExpr.name.lexeme).toBe('x')
  })

  test('array', () => {
    const statements = parse(`
      let x = [1,2]
      x[0]++
    `)
    expect(statements).toBeArrayOfSize(2)
    expect(statements[1]).toBeInstanceOf(ExpressionStatement)
    const exprStatement = statements[1] as ExpressionStatement
    expect(exprStatement.expression).toBeInstanceOf(UpdateExpression)
    const incrementExpr = exprStatement.expression as UpdateExpression
    expect(incrementExpr.operator.type).toBe('PLUS_PLUS')
    expect(incrementExpr.operand).toBeInstanceOf(GetExpression)
    const getExpr = incrementExpr.operand as GetExpression
    expect(getExpr.field.lexeme).toBe('0')
    expect(getExpr.obj).toBeInstanceOf(VariableExpression)
    const variableExpr = getExpr.obj as VariableExpression
    expect(variableExpr.name.lexeme).toBe('x')
  })

  test('dictionary', () => {
    const statements = parse(`
      let x = {"count": 1}
      x["count"]++
    `)
    expect(statements).toBeArrayOfSize(2)
    expect(statements[1]).toBeInstanceOf(ExpressionStatement)
    const exprStatement = statements[1] as ExpressionStatement
    expect(exprStatement.expression).toBeInstanceOf(UpdateExpression)
    const incrementExpr = exprStatement.expression as UpdateExpression
    expect(incrementExpr.operator.type).toBe('PLUS_PLUS')
    expect(incrementExpr.operand).toBeInstanceOf(GetExpression)
    const getExpr = incrementExpr.operand as GetExpression
    expect(getExpr.field.lexeme).toBe('"count"')
    expect(getExpr.obj).toBeInstanceOf(VariableExpression)
    const variableExpr = getExpr.obj as VariableExpression
    expect(variableExpr.name.lexeme).toBe('x')
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
        let movie = {"title": "The Matrix"}
        let title = movie["title"]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(VariableStatement)
      expect(stmts[1]).toBeInstanceOf(VariableStatement)
      const varStmtWithGet = stmts[1] as VariableStatement
      expect(varStmtWithGet.initializer).toBeInstanceOf(GetExpression)
      const getExpr = varStmtWithGet.initializer as GetExpression
      expect(getExpr.field.literal).toBe('title')
      expect(getExpr.obj).toBeInstanceOf(VariableExpression)
      expect((getExpr.obj as VariableExpression).name.lexeme).toBe('movie')
    })

    test('chained', () => {
      const stmts = parse(`
        let movie = {"director": {"name": "Peter Jackson"}}
        let director = movie["director"]["name"]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(VariableStatement)
      expect(stmts[1]).toBeInstanceOf(VariableStatement)
      const varStmtWithGet = stmts[1] as VariableStatement
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
        let scores = [7, 3, 10]
        let latest = scores[2]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(VariableStatement)
      expect(stmts[1]).toBeInstanceOf(VariableStatement)
      const varStmtWithGet = stmts[1] as VariableStatement
      expect(varStmtWithGet.initializer).toBeInstanceOf(GetExpression)
      const getExpr = varStmtWithGet.initializer as GetExpression
      expect(getExpr.field.literal).toBe(2)
      expect(getExpr.obj).toBeInstanceOf(VariableExpression)
      expect((getExpr.obj as VariableExpression).name.lexeme).toBe('scores')
    })

    test('chained', () => {
      const stmts = parse(`
        let scoreMinMax = [[3, 7], [1, 6]]
        let secondMin = scoreMinMax[1][0]
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(VariableStatement)
      expect(stmts[1]).toBeInstanceOf(VariableStatement)
      const varStmtWithGet = stmts[1] as VariableStatement
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
        let movie = {"title": "The Matrix"}
        movie["title"] = "Gladiator"
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(VariableStatement)
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
        let movie = {"director": {"name": "Peter Jackson"}}
        movie["director"]["name"] = "James Cameron"
      `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(VariableStatement)
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

  test('&&', () => {
    const stmts = parse('true && false')
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

  test('||', () => {
    const stmts = parse('true || false')
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

describe('ternary', () => {
  test('non-nested', () => {
    const stmts = parse('true ? 1 : 2')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const expStmt = stmts[0] as ExpressionStatement
    expect(expStmt.expression).toBeInstanceOf(TernaryExpression)
    const ternaryExpr = expStmt.expression as TernaryExpression
    expect(ternaryExpr.thenBranch).toBeInstanceOf(LiteralExpression)
    expect(ternaryExpr.elseBranch).toBeInstanceOf(LiteralExpression)
  })

  test('nested', () => {
    const stmts = parse('true ? 1 : false ? 2 : 3')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
    const expStmt = stmts[0] as ExpressionStatement
    expect(expStmt.expression).toBeInstanceOf(TernaryExpression)
    const ternaryExpr = expStmt.expression as TernaryExpression
    expect(ternaryExpr.thenBranch).toBeInstanceOf(LiteralExpression)
    expect(ternaryExpr.elseBranch).toBeInstanceOf(TernaryExpression)
    const nestedTernaryExpr = ternaryExpr.elseBranch as TernaryExpression
    expect(nestedTernaryExpr.thenBranch).toBeInstanceOf(LiteralExpression)
    expect(nestedTernaryExpr.elseBranch).toBeInstanceOf(LiteralExpression)
  })
})

describe('if', () => {
  test('without else', () => {
    const stmts = parse(`
      if (true) {
        let x = 1
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(VariableStatement)
    expect(expStmt.elseBranch).toBeNil()
  })

  test('with else', () => {
    const stmts = parse(`
      if (true) {
        let x = 1
      }
      else {
        let x = 2
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(VariableStatement)
    expect(expStmt.elseBranch).toBeInstanceOf(BlockStatement)
    const elseStmt = expStmt.elseBranch as BlockStatement
    expect(elseStmt.statements).toBeArrayOfSize(1)
    expect(elseStmt.statements[0]).toBeInstanceOf(VariableStatement)
  })

  test('nested', () => {
    const stmts = parse(`
      if (true) {
        let x = 1
      }
      else if (false) {
        let x = 2
      }
      else {
        let x = 3
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(IfStatement)
    const expStmt = stmts[0] as IfStatement
    expect(expStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(expStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const thenStmt = expStmt.thenBranch as BlockStatement
    expect(thenStmt.statements).toBeArrayOfSize(1)
    expect(thenStmt.statements[0]).toBeInstanceOf(VariableStatement)
    expect(expStmt.elseBranch).toBeInstanceOf(IfStatement)
    const elseIfStmt = expStmt.elseBranch as IfStatement
    expect(elseIfStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(elseIfStmt.thenBranch).toBeInstanceOf(BlockStatement)
    const elseIfStmtThenBlock = elseIfStmt.thenBranch as BlockStatement
    expect(elseIfStmtThenBlock.statements).toBeArrayOfSize(1)
    expect(elseIfStmtThenBlock.statements[0]).toBeInstanceOf(VariableStatement)
    expect(elseIfStmt.elseBranch).toBeInstanceOf(BlockStatement)
    const elseIfStmtElseBlock = elseIfStmt.elseBranch as BlockStatement
    expect(elseIfStmtElseBlock.statements).toBeArrayOfSize(1)
    expect(elseIfStmtElseBlock.statements[0]).toBeInstanceOf(VariableStatement)
  })
})

describe('while', () => {
  test('with single statement', () => {
    const stmts = parse(`
      while (true) {
        let x = 1
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(WhileStatement)
    const expStmt = stmts[0] as WhileStatement
    expect(expStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(expStmt.body).toBeArrayOfSize(1)
    expect(expStmt.body[0]).toBeInstanceOf(VariableStatement)
  })
})

describe('do while', () => {
  test('with single statement', () => {
    const stmts = parse(`
      do {
        let x = 1
      }
      while (true)
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(DoWhileStatement)
    const expStmt = stmts[0] as DoWhileStatement
    expect(expStmt.condition).toBeInstanceOf(LiteralExpression)
    expect(expStmt.body).toBeArrayOfSize(1)
    expect(expStmt.body[0]).toBeInstanceOf(VariableStatement)
  })
})

describe('block', () => {
  test('non-nested', () => {
    const stmts = parse(`
      {
        let x = 1
        let y = 2
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(BlockStatement)
    const blockStmt = stmts[0] as BlockStatement
    expect(blockStmt.statements).toBeArrayOfSize(2)
    expect(blockStmt.statements[0]).toBeInstanceOf(VariableStatement)
    expect(blockStmt.statements[1]).toBeInstanceOf(VariableStatement)
  })

  test('nested', () => {
    const stmts = parse(`
      {
        let x = 1
        {
          let y = 2
        }
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(BlockStatement)
    const blockStmt = stmts[0] as BlockStatement
    expect(blockStmt.statements).toBeArrayOfSize(2)
    expect(blockStmt.statements[0]).toBeInstanceOf(VariableStatement)
    expect(blockStmt.statements[1]).toBeInstanceOf(BlockStatement)
  })
})

describe('function', () => {
  test('without parameters', () => {
    const stmts = parse(`
      function move() {
        return 1
      }
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
      function move(from, to) {
        return from + to
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionStatement)
    const functionStmt = stmts[0] as FunctionStatement
    expect(functionStmt.name.lexeme).toBe('move')
    expect(functionStmt.parameters).toBeArrayOfSize(2)
    expect(functionStmt.parameters[0].name.lexeme).toBe('from')
    expect(functionStmt.parameters[1].name.lexeme).toBe('to')
    expect(functionStmt.body).toBeArrayOfSize(1)
    expect(functionStmt.body[0]).toBeInstanceOf(ReturnStatement)
  })

  test('with default parameter', () => {
    const stmts = parse(`
      function move(from = 0, to = 10) {
        return from + to
      }
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionStatement)
    const functionStmt = stmts[0] as FunctionStatement
    expect(functionStmt.name.lexeme).toBe('move')
    expect(functionStmt.parameters).toBeArrayOfSize(2)
    expect(functionStmt.parameters[0].name.lexeme).toBe('from')
    expect(functionStmt.parameters[1].name.lexeme).toBe('to')
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

describe('error', () => {
  describe('number', () => {
    test('two periods', () => {
      expect(() => parse('1.3.4')).toThrow(
        'A number can only have one decimal point. Did you mean `1.34`?'
      )
    })
  })
  describe('string', () => {
    test('unstarted', () => {
      expect(() => parse('abc"')).toThrow(
        'Did you forget the start quote for the "abc" string?'
      )
    })
    test('unterminated - end of file', () => {
      expect(() => parse('"abc')).toThrow(
        `Did you forget to add end quote? Maybe you meant to write:\n\n\`\`\`\"abc\"\`\`\``
      )
    })
    test('unterminated - end of line', () => {
      expect(() => parse('"abc\nsomething_else"')).toThrow(
        `Did you forget to add end quote? Maybe you meant to write:\n\n\`\`\`\"abc\"\`\`\``
      )
    })
    test('unterminated - newline in string', () => {
      expect(() => parse('"abc\n"')).toThrow(
        `Did you forget to add end quote? Maybe you meant to write:\n\n\`\`\`\"abc\"\`\`\``
      )
    })
  })

  describe('call', () => {
    test('missing opening parenthesis', () => {
      expect(() =>
        parse(`
          function move() {
            return 1
          }

          move)
        `)
      ).toThrow(
        'Did you forget the start parenthesis when trying to call the move function?'
      )
    })

    test('missing closing parenthesis', () => {
      expect(() => parse('move(1')).toThrow(
        'Did you forget the end parenthesis when trying to call the move function?'
      )
    })
  })

  describe('statement', () => {
    test('multiple expressions on single line', () => {
      expect(() => parse('1 1')).toThrow(
        "We didn't expect `{{current}}` to appear on this line after the `{{previous}}`. {{suggestion}}"
      )
    })
  })
})

describe('white space', () => {
  test('skip over empty lines', () => {
    const stmts = parse(`
      let a = 19

      \t\t\t
      let x = true

      let y = false
      \t

    `)
    expect(stmts).toBeArrayOfSize(3)
    expect(stmts[0]).toBeInstanceOf(VariableStatement)
    expect(stmts[1]).toBeInstanceOf(VariableStatement)
    expect(stmts[2]).toBeInstanceOf(VariableStatement)
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
      const statements = parse('let x = 1')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(VariableStatement)
      const expressionStatement = statements[0] as VariableStatement
      expect(expressionStatement.location.line).toBe(1)
      expect(expressionStatement.location.relative.begin).toBe(1)
      expect(expressionStatement.location.relative.end).toBe(10)
      expect(expressionStatement.location.absolute.begin).toBe(1)
      expect(expressionStatement.location.absolute.end).toBe(10)
    })

    test('const', () => {
      const statements = parse('const x = 1')
      expect(statements).toBeArrayOfSize(1)
      expect(statements[0]).toBeInstanceOf(ConstantStatement)
      const expressionStatement = statements[0] as ConstantStatement
      expect(expressionStatement.location.line).toBe(1)
      expect(expressionStatement.location.relative.begin).toBe(1)
      expect(expressionStatement.location.relative.end).toBe(12)
      expect(expressionStatement.location.absolute.begin).toBe(1)
      expect(expressionStatement.location.absolute.end).toBe(12)
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
