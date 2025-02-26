import { interpret } from '@/interpreter/interpreter'
import { parse } from '@/interpreter/parser'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangeElementStatement,
  LogStatement,
  SetVariableStatement,
} from '@/interpreter/statement'
import {
  AccessorExpression,
  BinaryExpression,
  FunctionCallExpression,
  GetElementExpression,
  ListExpression,
  LiteralExpression,
  LogicalExpression,
  UnaryExpression,
  VariableLookupExpression,
} from '@/interpreter/expression'
import { unwrapJikiObject } from '@/interpreter/jikiObjects'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('parse', () => {
  test('empty', () => {
    const stmts = parse('log []')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeEmpty()
  })

  test('single element', () => {
    const stmts = parse('log [1]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(1)
    expect(listExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    const firstElemExpr = listExpr.elements[0] as LiteralExpression
    expect(firstElemExpr.value).toBe(1)
  })

  test('multiple elements', () => {
    const stmts = parse('log [1,2,3]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(3)
    expect(listExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect(listExpr.elements[1]).toBeInstanceOf(LiteralExpression)
    expect(listExpr.elements[2]).toBeInstanceOf(LiteralExpression)
    expect((listExpr.elements[0] as LiteralExpression).value).toBe(1)
    expect((listExpr.elements[1] as LiteralExpression).value).toBe(2)
    expect((listExpr.elements[2] as LiteralExpression).value).toBe(3)
  })

  test('multiple elements over lines - simple', () => {
    const stmts = parse(`
    log [ 1,
    2,
      3
    ]`)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(3)
    expect((listExpr.elements[0] as LiteralExpression).value).toBe(1)
    expect((listExpr.elements[1] as LiteralExpression).value).toBe(2)
    expect((listExpr.elements[2] as LiteralExpression).value).toBe(3)
  })

  test('multiple elements over lines - complex', () => {
    const stmts = parse(`log [
                              1,
                              2,
                              3
                             ]`)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(3)
    expect((listExpr.elements[0] as LiteralExpression).value).toBe(1)
    expect((listExpr.elements[1] as LiteralExpression).value).toBe(2)
    expect((listExpr.elements[2] as LiteralExpression).value).toBe(3)
  })

  test('or with function call as an elem', () => {
    const stmts = parse('log [foo() or true]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(1)
    expect(listExpr.elements[0]).toBeInstanceOf(LogicalExpression)
    const orExpr = listExpr.elements[0] as LogicalExpression
    expect(orExpr.left).toBeInstanceOf(FunctionCallExpression)
    expect(orExpr.right).toBeInstanceOf(LiteralExpression)
    const callExpr = orExpr.left as FunctionCallExpression
    expect(callExpr.callee.name.lexeme).toBe('foo')
  })

  test('nested', () => {
    const stmts = parse('log [1,[2,[3]]]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(2)
    expect(listExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect((listExpr.elements[0] as LiteralExpression).value).toBe(1)
    expect(listExpr.elements[1]).toBeInstanceOf(ListExpression)
    const nestedExpr = listExpr.elements[1] as ListExpression
    expect(nestedExpr.elements).toBeArrayOfSize(2)
    expect(nestedExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect((nestedExpr.elements[0] as LiteralExpression).value).toBe(2)
    expect(nestedExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    const nestedNestedExpr = nestedExpr.elements[1] as ListExpression
    expect(nestedNestedExpr.elements).toBeArrayOfSize(1)
    expect(nestedNestedExpr.elements[0]).toBeInstanceOf(LiteralExpression)
    expect((nestedNestedExpr.elements[0] as LiteralExpression).value).toBe(3)
  })

  test('expressions', () => {
    const stmts = parse('log [-1,2*2,3+3]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const logStmt = stmts[0] as LogStatement
    expect(logStmt.expression).toBeInstanceOf(ListExpression)
    const listExpr = logStmt.expression as ListExpression
    expect(listExpr.elements).toBeArrayOfSize(3)
    expect(listExpr.elements[0]).toBeInstanceOf(UnaryExpression)
    expect(listExpr.elements[1]).toBeInstanceOf(BinaryExpression)
    expect(listExpr.elements[2]).toBeInstanceOf(BinaryExpression)
  })
  test('create', () => {
    const stmts = parse(`set scores to [7, 3, 10]`)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
  })
  describe('index access', () => {
    test('literal', () => {
      const stmts = parse(`log ["f", "o", "o", "b", "a", "r"][4] `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getExpr = logStmt.expression as GetElementExpression
      expect(getExpr.obj).toBeInstanceOf(ListExpression)
      expect(getExpr.field).toBeInstanceOf(LiteralExpression)

      expect(
        (getExpr.obj as ListExpression).elements.map((e) => e.value)
      ).toEqual(['f', 'o', 'o', 'b', 'a', 'r'])
      expect((getExpr.field as LiteralExpression).value).toBe(4)
    })
    test('expression', () => {
      const stmts = parse(`log ["f", "o", "o", "b", "a", "r"][4 + 1] `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getExpr = logStmt.expression as GetElementExpression
      expect(getExpr.obj).toBeInstanceOf(ListExpression)
      expect(getExpr.field).toBeInstanceOf(BinaryExpression)

      expect(
        (getExpr.obj as ListExpression).elements.map((e) => e.value)
      ).toEqual(['f', 'o', 'o', 'b', 'a', 'r'])

      const fieldExpr = getExpr.field as BinaryExpression
      expect(fieldExpr.operator.lexeme).toBe('+')
      expect(fieldExpr.left).toBeInstanceOf(LiteralExpression)
      expect(fieldExpr.right).toBeInstanceOf(LiteralExpression)
      expect((fieldExpr.left as LiteralExpression).value).toBe(4)
      expect((fieldExpr.right as LiteralExpression).value).toBe(1)
    })
  })

  describe('change element', () => {
    test('to a string', () => {
      const stmts = parse(`change scores[2] to "Hello"`)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ChangeElementStatement)

      const changeStmt = stmts[0] as ChangeElementStatement
      expect(changeStmt.object).toBeInstanceOf(VariableLookupExpression)
      const lookupExpr = changeStmt.object as VariableLookupExpression
      expect(lookupExpr.name.lexeme).toBe('scores')

      expect(changeStmt.field).toBeInstanceOf(LiteralExpression)
      const indexExpr = changeStmt.field as LiteralExpression
      expect(indexExpr.value).toBe(2)
    })

    test('to a variable', () => {
      const stmts = parse(`change scores[foo] to 1`)
      expect(stmts).toBeArrayOfSize(1)
      const changeStmt = stmts[0] as ChangeElementStatement
      expect(changeStmt.field).toBeInstanceOf(VariableLookupExpression)
      const indexExpr = changeStmt.field as VariableLookupExpression
      expect(indexExpr.name.lexeme).toBe('foo')
    })

    test('to a function call', () => {
      const stmts = parse(`change scores[foo()] to 1`)
      expect(stmts).toBeArrayOfSize(1)
      const changeStmt = stmts[0] as ChangeElementStatement
      expect(changeStmt.field).toBeInstanceOf(FunctionCallExpression)
      const indexExpr = changeStmt.field as FunctionCallExpression
      expect(indexExpr.callee.name.lexeme).toBe('foo')
    })
    test('with chained method', () => {
      const stmts = parse('change foo.bar[0] to true')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ChangeElementStatement)

      const changeStmt = stmts[0] as ChangeElementStatement

      expect(changeStmt.object).toBeInstanceOf(AccessorExpression)
      const accessorExpr = changeStmt.object as AccessorExpression
      expect(accessorExpr.property.lexeme).toBe('bar')
      expect(accessorExpr.object).toBeInstanceOf(VariableLookupExpression)

      expect(changeStmt.field).toBeInstanceOf(LiteralExpression)
      const fieldExpr = changeStmt.field as LiteralExpression
      expect(fieldExpr.value).toBe(0)
    })
  })

  test('access single field', () => {
    const stmts = parse(`
          set scores to [7, 3, 10]
          set latest to scores[2]
        `)
    expect(stmts).toBeArrayOfSize(2)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
    expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
    const varStmtWithGet = stmts[1] as SetVariableStatement
    expect(varStmtWithGet.value).toBeInstanceOf(GetElementExpression)
    const getExpr = varStmtWithGet.value as GetElementExpression
    expect((getExpr.field as LiteralExpression).value).toBe(2)
    expect(getExpr.obj).toBeInstanceOf(VariableLookupExpression)
    expect((getExpr.obj as VariableLookupExpression).name.lexeme).toBe('scores')
  })

  test('set nested', () => {
    const stmts = parse(`
          set scoreMinMax to [[3, 7], [1, 6]]
        `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
  })

  test('access nested', () => {
    const stmts = parse(`
          set scoreMinMax to [[3, 7], [1, 6]]
          set secondMin to scoreMinMax[1][0]
        `)
    expect(stmts).toBeArrayOfSize(2)
    expect(stmts[0]).toBeInstanceOf(SetVariableStatement)

    expect(stmts[1]).toBeInstanceOf(SetVariableStatement)
    const varStmtWithGet = stmts[1] as SetVariableStatement
    expect(varStmtWithGet.value).toBeInstanceOf(GetElementExpression)
    const getExpr = varStmtWithGet.value as GetElementExpression
    expect((getExpr.field as LiteralExpression).value).toBe(0)
    expect(getExpr.obj).toBeInstanceOf(GetElementExpression)
    const nestedGetExpr = getExpr.obj as GetElementExpression
    expect((nestedGetExpr.field as LiteralExpression).value).toBe(1)
    expect(nestedGetExpr.obj).toBeInstanceOf(VariableLookupExpression)
    expect((nestedGetExpr.obj as VariableLookupExpression).name.lexeme).toBe(
      'scoreMinMax'
    )
  })
})

describe('execute', () => {
  describe('set', () => {
    test('set list', () => {
      const { frames } = interpret(`
      set scores to [7, 3, 10]
    `)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        scores: [7, 3, 10],
      })
    })
  })
  describe('change', () => {
    test('to string', () => {
      const { frames } = interpret(`
      set scores to [7, 3, 10]
      change scores[2] to "foo"
    `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        scores: [7, 'foo', 10],
      })
    })
    test('functions', () => {
      const { frames } = interpret(`
      function ret_2 do
        return 2
      end
      function ret_true do
        return true
      end
      set scores to [7, 3, 10]
      change scores[ret_2()] to ret_true()
    `)
      expect(frames).toBeArrayOfSize(4)
      expect(frames[3].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[3].variables)).toMatchObject({
        scores: [7, true, 10],
      })
    })
    test('variables', () => {
      const { frames } = interpret(`
      set ret_2 to 2
      set ret_true to true
      set scores to [7, 3, 10]
      change scores[ret_2] to ret_true
    `)
      expect(frames).toBeArrayOfSize(4)
      expect(frames[3].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[3].variables)).toMatchObject({
        scores: [7, true, 10],
      })
    })
  })

  describe('get', () => {
    test('single index', () => {
      const { frames } = interpret(`
      set scores to [7, 3, 10]
      set latest to scores[2]
    `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        scores: [7, 3, 10],
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        scores: [7, 3, 10],
        latest: 3,
      })
    })
    test('function', () => {
      const { frames } = interpret(`
      function ret_2 do
        return 2
      end
      set scores to [7, 3, 10]
      set latest to scores[ret_2()]
    `)
      expect(frames).toBeArrayOfSize(3)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        scores: [7, 3, 10],
      })
      expect(frames[2].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[2].variables)).toMatchObject({
        scores: [7, 3, 10],
        latest: 3,
      })
    })

    test('chained', () => {
      const { frames } = interpret(`
      set scoreMinMax to [["a", "b"], ["c", "d"]]
      set secondMin to scoreMinMax[2][1]
    `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        scoreMinMax: [
          ['a', 'b'],
          ['c', 'd'],
        ],
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        scoreMinMax: [
          ['a', 'b'],
          ['c', 'd'],
        ],
        secondMin: 'c',
      })
    })
  })
  describe('index access', () => {
    test('single', () => {
      const { frames } = interpret(`log ["f", "o", "o", "b", "a", "r"][4] `)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].result?.jikiObject?.value).toBe('b')
    })
    test('expression', () => {
      const { frames } = interpret(`log ["f", "o", "o", "b", "a", "r"][4 + 1] `)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].result?.jikiObject?.value).toBe('a')
    })
  })
})
