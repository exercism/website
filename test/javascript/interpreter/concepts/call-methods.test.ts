import { parse } from '@/interpreter/parser'
import { interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import {
  LogStatement,
  MethodCallStatement,
  MethodStatement,
  ReturnStatement,
} from '@/interpreter/statement'
import { last } from 'lodash'
import { unwrapJikiObject } from '@/interpreter/jikiObjects'
import {
  MethodCallExpression,
  LiteralExpression,
  GetElementExpression,
  VariableLookupExpression,
} from '@/interpreter/expression'
import { Token } from 'marked'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('parse', () => {
  describe.skip('statement', () => {
    test('without arguments', () => {
      const stmts = parse('foo.bar()')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(MethodCallStatement)
      const expStmt = stmts[0] as MethodCallStatement
      expect(expStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = expStmt.expression as MethodCallExpression
      expect(callExpr.args).toBeEmpty()
    })

    test.skip('single argument', () => {
      const stmts = parse('foo.bar("left")')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(MethodCallStatement)
      const logStmt = stmts[0] as MethodCallStatement
      expect(logStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = logStmt.expression as MethodCallExpression
      expect(callExpr.args).toBeArrayOfSize(1)
      expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
    })
  })
  describe('expression', () => {
    test('without arguments', () => {
      const stmts = parse('log foo.bar()')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const expStmt = stmts[0] as LogStatement
      expect(expStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = expStmt.expression as MethodCallExpression
      expect(callExpr.args).toBeEmpty()
    })

    test('single argument', () => {
      const stmts = parse('log foo.bar("left")')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = logStmt.expression as MethodCallExpression
      expect(callExpr.object).toBeInstanceOf(VariableLookupExpression)
      expect(callExpr.args).toBeArrayOfSize(1)
      expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
    })

    test('chained before', () => {
      const stmts = parse('log foo[0].bar()')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const expStmt = stmts[0] as LogStatement
      expect(expStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = expStmt.expression as MethodCallExpression
      expect(callExpr.object).toBeInstanceOf(GetElementExpression)
      expect(callExpr.method.lexeme).toBe('bar')
      expect(callExpr.args).toBeEmpty()
    })
    test('chained after', () => {
      const stmts = parse('log foo.bar("left")[0]')
      console.log(stmts[0])
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)

      const logStmt = stmts[0] as LogStatement

      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getStmt = logStmt.expression as GetElementExpression

      expect(getStmt.obj).toBeInstanceOf(MethodCallExpression)
      const callExpr = getStmt.obj as MethodCallExpression
      expect(callExpr.method.lexeme).toBe('bar')
      expect(callExpr.object).toBeInstanceOf(VariableLookupExpression)
      expect(callExpr.args).toBeArrayOfSize(1)
      expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
      expect((callExpr.args[0] as LiteralExpression).value).toBe('left')

      expect(getStmt.field).toBeInstanceOf(LiteralExpression)
      const fieldExpr = getStmt.field as LiteralExpression
      expect(fieldExpr.value).toBe(0)
    })
  })
})

describe.skip('interpret', () => {
  describe('pass by value', () => {
    test('lists', () => {
      const { frames } = interpret(`
      set original to [1, 2, 3]
      function increment with list do
        change list[1] to list[1] + 1
        change list[2] to list[2] + 1
        change list[3] to list[3] + 1
      end
      increment(original)
      log original
    `)
      // Inside the function
      const finalMethodFrame = frames[frames.length - 3]
      expect(unwrapJikiObject(finalMethodFrame.variables)['list']).toEqual([
        2, 3, 4,
      ])

      // After the function
      const lastFrame = frames[frames.length - 1]
      expect(unwrapJikiObject(lastFrame.variables)['original']).toEqual([
        1, 2, 3,
      ])
    })
  })
})
