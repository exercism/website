import { interpret } from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import {
  LiteralExpression,
  VariableLookupExpression,
} from '@/interpreter/expression'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'
import { type Token, TokenType } from '@/interpreter/token'
import { SetVariableStatement } from '@/interpreter/statement'
import { describeFrame } from '@/interpreter/frames'

const location = new Location(0, new Span(0, 0), new Span(0, 0))
const getNameFunction = {
  name: 'get_name',
  func: (_interpreter: any) => {
    return 'Jeremy'
  },
  description: '',
}
const getTrueFunction = {
  name: 'get_true',
  func: (_interpreter: any) => {
    return true
  },
  description: '',
}
const getFalseFunction = {
  name: 'get_false',
  func: (_interpreter: any) => {
    return false
  },
  description: '',
}

describe('SetVariableStatement', () => {
  describe('description', () => {
    test('standard', () => {
      const { frames } = interpret('set my_name to "Jeremy"')
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        '<p>This created a new variable called <code>my_name</code> and sets its value to <code>"Jeremy"</code>.</p>'
      )
    })
    test('function', () => {
      const { frames } = interpret('set my_name to get_name()', {
        externalFunctions: [getNameFunction],
      })
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

describe('IfStatement', () => {
  describe('description', () => {
    test('booleans', () => {
      const { error, frames } = interpret(`
        if true is true do
          set name to "Jeremy"
        end
      `)
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        `<p>This checked whether <code>true</code> was equal to <code>true</code></p>\n<p>The result was <code>true</code>.</p>`
      )
    })
    test('booleans and', () => {
      const { error, frames } = interpret(`
        if true is true and true is true do
          set name to "Jeremy"
        end
      `)
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        `<p>This checked whether both of these were true:</p><ul><li><code>true</code> was equal to <code>true</code></li><li><code>true</code> was equal to <code>true</code></li></ul><p></p>\n<p>The result was <code>true</code>.</p>`
      )
    })
    test('function vs boolean', () => {
      const { error, frames } = interpret(
        `
        if get_true() is true do
          set name to "Jeremy"
        end
      `,
        { externalFunctions: [getTrueFunction] }
      )
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        `<p>This checked whether <code>get_true()</code> (which returned <code>true</code>) was equal to <code>true</code></p>\n<p>The result was <code>true</code>.</p>`
      )
    })
    test('boolean vs function', () => {
      const { error, frames } = interpret(
        `
        if true is get_true() do
          set name to "Jeremy"
        end
      `,
        { externalFunctions: [getTrueFunction] }
      )
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        `<p>This checked whether <code>true</code> was equal to <code>get_true()</code> (which returned <code>true</code>)</p>\n<p>The result was <code>true</code>.</p>`
      )
    })
    test('function vs function', () => {
      const { error, frames } = interpret(
        `
        if get_true()  is get_false() do
          set name to "Jeremy"
        end
      `,
        { externalFunctions: [getTrueFunction, getFalseFunction] }
      )
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        `<p>This checked whether <code>get_true()</code> (which returned <code>true</code>) was equal to <code>get_false()</code> (which returned <code>false</code>)</p>\n<p>The result was <code>false</code>.</p>`
      )
    })
    test('function vs function with and', () => {
      const { error, frames } = interpret(
        `
        if get_true() is get_true() and get_false() is get_false() do
          set name to "Jeremy"
        end
      `,
        { externalFunctions: [getTrueFunction, getFalseFunction] }
      )
      const actual = describeFrame(frames[0], [])
      expect(actual).toBe(
        `<p>This checked whether both of these were true:</p><ul><li><code>get_true()</code> (which returned <code>true</code>) was equal to <code>get_true()</code> (which returned <code>true</code>)</li><li><code>get_false()</code> (which returned <code>false</code>) was equal to <code>get_false()</code> (which returned <code>false</code>)</li></ul><p></p>\n<p>The result was <code>true</code>.</p>`
      )
    })
  })
})

describe('ReturnStatement', () => {
  test('no value', () => {
    const { frames } = interpret(`
      function get_name do
        return
      end
      get_name()
    `)
    const actual = describeFrame(frames[0], [])
    expect(actual).toBe('<p>This exited the function.</p>')
  })
  test('variable', () => {
    const { frames } = interpret(`
      function get_name do
        set x to 1
        return x
      end
      get_name()
    `)
    const actual = describeFrame(frames[1], [])
    expect(actual).toBe(
      '<p>This returned the value of <code>x</code>, which in this case is <code>1</code>.</p>'
    )
  })
  test('complex option', () => {
    const { frames } = interpret(`
      function get_3 do
        return 3
      end
      function get_name do
        return get_3()
      end
      get_name()
    `)
    const actual = describeFrame(frames[1], [])
    expect(actual).toBe('<p>This returned <code>3</code>.</p>')
  })
  test('literal', () => {
    const { frames } = interpret(`
      function get_name do
        return 1
      end
      get_name()
    `)
    const actual = describeFrame(frames[0], [])
    expect(actual).toBe('<p>This returned <code>1</code>.</p>')
  })
})
