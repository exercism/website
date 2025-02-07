import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

test('literal', () => {
  const { frames } = interpret('set my_name to "Jeremy"')
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called <code>my_name</code> and set its value to <code>"Jeremy"</code>.</p>`,
    [
      `<li>Jiki created a new box called <code>my_name</code>.</li>`,
      `<li>Jiki put <code>"Jeremy"</code> in the box.</li>`,
    ]
  )
})

test('function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('set my_name to get_name()', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called<code>my_name</code>and set its value to <code>"Jeremy"</code>.</p>`,
    [
      `<li>Jiki used the <code>get_name()</code> function, which returned <code>"Jeremy"</code>.</li>`,
      `<li>Jiki created a new box called <code>my_name</code>.</li>`,
      `<li>Jiki put <code>"Jeremy"</code> in the box.</li>`,
    ]
  )
})

test('binary comparison', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret('set a_bool to 5 > 3', context)
  const actual = describeFrame(frames[0], [])
  assertHTML(
    actual,
    `<p>This created a new variable called<code>a_bool</code>and set its value to <code>true</code>.</p>`,
    [
      `<li>Jiki evaluated <code>5 > 3</code> and determined it was <code>true</code>.</li>`,
      `<li>Jiki created a new box called <code>a_bool</code>.</li>`,
      `<li>Jiki put <code>true</code> in the box.</li>`,
    ]
  )
})
