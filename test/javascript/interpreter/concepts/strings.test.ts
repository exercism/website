import { interpret } from '@/interpreter/interpreter'
import { parse } from '@/interpreter/parser'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangeListElementStatement,
  LogStatement,
  SetVariableStatement,
} from '@/interpreter/statement'
import {
  BinaryExpression,
  CallExpression,
  GetExpression,
  ListExpression,
  LiteralExpression,
  UnaryExpression,
  VariableLookupExpression,
} from '@/interpreter/expression'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('lists', () => {
  describe('parse', () => {
    test('literal', () => {
      const stmts = parse('log "nice"')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(LiteralExpression)
      const literalExpr = logStmt.expression as LiteralExpression
      expect(literalExpr.value).toBe('nice')
    })
  })

  describe('execute', () => {
    test('set', () => {
      const { frames } = interpret('set x to "hello there"')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 'hello there' })
    })

    test('log', () => {
      const { frames } = interpret(`log "foobar"`)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].result?.value.value).toBe('foobar')
    })

    test('iterate', () => {
      const { frames } = interpret(`
        for each char in "ab" do
          log char
        end
      `)
      expect(frames).toBeArrayOfSize(5)
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].result?.value.value).toBe('a')
      expect(frames[4].result?.value.value).toBe('b')
    })

    test('index access', () => {
      const { frames } = interpret(`log "foobar"[4] `)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].result?.value.value).toBe('b')
    })
  })
})
