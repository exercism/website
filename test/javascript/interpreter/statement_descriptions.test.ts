import { interpret } from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import { LiteralExpression, VariableExpression } from '@/interpreter/expression'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'
import { type Token, TokenType } from '@/interpreter/token'
import { SetVariableStatement } from '@/interpreter/statement'

const location = new Location(0, new Span(0, 0), new Span(0, 0))

describe('SetVariableStatement', () => {
  describe('description', () => {
    test('standard', () => {
      const { frames } = interpret('set my_name to "Jeremy"')
      const actual = (frames[0].context as SetVariableStatement).description()
      expect(actual).toBe(
        '<p>This created a new variable called <code>my_name</code> and sets it to be equal to <code>"Jeremy"</code>.</p>'
      )
    })
  })
})
