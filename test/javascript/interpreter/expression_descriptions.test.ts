import { interpret } from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import { LiteralExpression, VariableExpression } from '@/interpreter/expression'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'
import { type Token, TokenType } from '@/interpreter/token'

const location = new Location(0, new Span(0, 0), new Span(0, 0))

describe('LiteralExpression', () => {
  describe('description', () => {
    test('number', () => {
      const expr = new LiteralExpression(1, location)
      const actual = expr.description()
      expect(actual).toBe('<code>1</code>')
    })
    test('boolean', () => {
      const expr = new LiteralExpression(true, location)
      const actual = expr.description()
      expect(actual).toBe('<code>true</code>')
    })
    test('string', () => {
      const expr = new LiteralExpression('hello', location)
      const actual = expr.description()
      expect(actual).toBe('<code>"hello"</code>')
    })
  })
})

describe('VariableExpression', () => {
  describe('description', () => {
    test('number', () => {
      const token: Token = {
        lexeme: 'name',
        type: 'NUMBER',
        literal: 'name',
        location: location,
      }
      const expr = new VariableExpression(token, location)
      const actual = expr.description()
      expect(actual).toBe('the <code>name</code> variable')
    })
  })
})
