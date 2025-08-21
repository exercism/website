import { parse } from '@/interpreter/parser'
import { interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import { ReturnStatement } from '@/interpreter/statement'
import { LiteralExpression } from '@/interpreter/expression'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('return', () => {
  describe('parse', () => {
    test('without argument', () => {
      const stmts = parse('return')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ReturnStatement)
      const returnStmt = stmts[0] as ReturnStatement
      expect(returnStmt.expression).toBeNull()
    })

    describe('with argument', () => {
      test('number', () => {
        const stmts = parse('return 2')
        expect(stmts).toBeArrayOfSize(1)
        expect(stmts[0]).toBeInstanceOf(ReturnStatement)
        const returnStmt = stmts[0] as ReturnStatement
        expect(returnStmt.expression).toBeInstanceOf(LiteralExpression)
        const literalExpr = returnStmt.expression as LiteralExpression
        expect(literalExpr.value).toBe(2)
      })

      test('string', () => {
        const stmts = parse('return "hello there!"')
        expect(stmts).toBeArrayOfSize(1)
        expect(stmts[0]).toBeInstanceOf(ReturnStatement)
        const returnStmt = stmts[0] as ReturnStatement
        expect(returnStmt.expression).toBeInstanceOf(LiteralExpression)
        const literalExpr = returnStmt.expression as LiteralExpression
        expect(literalExpr.value).toBe('hello there!')
      })
    })
  })
})
