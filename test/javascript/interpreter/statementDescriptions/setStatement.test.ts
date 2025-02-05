import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

test('literal', () => {
  const { frames } = interpret('set my_name to "Jeremy"')
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    '<p>This created a new variable called <code>my_name</code> and set its value to <code>"Jeremy"</code>.</p>'
  )
})

test('function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('set my_name to get_name()', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called<code>my_name</code>and set its value to the value returned from<code>get_name()</code> (<code>"Jeremy"</code>).</p>`
  )
})

test('binary comparison', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('set my_name to 5 > 3', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called<code>my_name</code>and set its value to <code>true</code>.</p>`
  )
})

test('binary comparison', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('set my_name to true and false', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called<code>my_name</code>and set its value to <code>false</code>.</p>`
  )
})
