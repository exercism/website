import { interpret } from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import { LiteralExpression, VariableExpression } from '@/interpreter/expression'
import { Location } from '@/interpreter/location'
import { Span } from '@/interpreter/location'
import { type Token, TokenType } from '@/interpreter/token'
import { SetVariableStatement } from '@/interpreter/statement'
import { describeFrame } from '@/interpreter/frames'
import { marked } from 'marked'

const location = new Location(0, new Span(0, 0), new Span(0, 0))
const assertMarkdown = (actual, markdown) => {
  markdown = markdown
    .split('\n')
    .map((line) => line.trim())
    .join('\n')
  expect(actual).toBe(marked.parse(markdown))
}

test('if true', () => {
  const { error, frames } = interpret(`
      if true do
      end
    `)
  const actual = describeFrame(frames[0], [])
  assertMarkdown(
    actual,
    `
      This checked whether \`true\` was \`true\`
      
      The result was \`true\`.
    `
  )
})
test('if (true)', () => {
  const { frames } = interpret(`
      if (true) do
      end
    `)
  const actual = describeFrame(frames[0], [])
  assertMarkdown(
    actual,
    `
      This checked whether \`true\` was \`true\`
      
      The result was \`true\`.
    `
  )
})
test('if fn()', () => {
  const { frames } = interpret(`
      function ret_true do
        return true
      end
      if ret_true() do
      end
    `)
  const actual = describeFrame(frames[1], [])
  assertMarkdown(
    actual,
    `
      This checked whether \`ret_true()\` returned \`true\`
      
      The result was \`true\`.
    `
  )
})
test('if fn() is true', () => {
  const { frames } = interpret(`
      function ret_true do
        return true
      end
      if ret_true() is true do
      end
    `)
  const actual = describeFrame(frames[1], [])
  assertMarkdown(
    actual,
    `
      This checked whether \`ret_true()\` returned \`true\`
      
      The result was \`true\`.
    `
  )
})

describe.skip('IfStatement', () => {
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
