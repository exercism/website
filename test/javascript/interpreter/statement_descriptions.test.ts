import { interpret } from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import { LiteralExpression, VariableExpression } from '@/interpreter/expression'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'
import { type Token, TokenType } from '@/interpreter/token'
import { SetVariableStatement } from '@/interpreter/statement'
import { describeFrame } from '@/interpreter/frames'

const location = new Location(0, new Span(0, 0), new Span(0, 0))

describe('SetVariableStatement', () => {
  describe('description', () => {
    test('standard', () => {
      const { frames } = interpret('set my_name to "Jeremy"')
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        '<p>This created a new variable called <code>my_name</code> and sets its value to <code>"Jeremy"</code>.</p>'
      )
    })
  })
})

describe('ChangeVariableStatement', () => {
  describe('description', () => {
    test('standard', () => {
      const { frames } = interpret(`
        set my_name to "Aron"
        change my_name to "Jeremy"
        `)
      const actual = describeFrame(frames[1], [])
      expect(actual).toBe(
        '<p>This updated the variable called <code>my_name</code> from...</p><pre><code>"Aron"</code></pre><p>to...</p><pre><code>"Jeremy"</code></pre>'
      )
    })
  })
})
