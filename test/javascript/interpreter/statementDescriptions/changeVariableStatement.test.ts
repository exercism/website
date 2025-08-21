import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

test('literal', () => {
  const { frames } = interpret(`
    set my_name to ""
    change my_name to "Jeremy"
    `)
  const actual = describeFrame(frames[1])
  assertHTML(
    actual,
    `<p>This changed the value in <code>my_name</code> to <code>"Jeremy"</code>.</p>`,
    [
      `<li>Jiki found the<code>my_name</code>box.</li>`,
      `<li>Jiki removed the existing contents (<code>""</code>) from the box.</li>`,
      `<li>Jiki put <code>"Jeremy"</code> in the box.</li>`,
    ]
  )
})

test('function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const { frames } = interpret(
    `
    set my_name to "foo"
    change my_name to get_name()
    `,
    context
  )
  const actual = describeFrame(frames[1])
  assertHTML(
    actual,
    `<p>This changed the value in <code>my_name</code> to <code>"Jeremy"</code>.</p>`,
    [
      `<li>Jiki used the<code>get_name()</code>function, which returned<code>\"Jeremy\"</code>.</li>`,
      `<li>Jiki found the<code>my_name</code>box.</li>`,
      `<li>Jiki removed the existing contents (<code>"foo"</code>) from the box.</li>`,
      `<li>Jiki put <code>"Jeremy"</code> in the box.</li>`,
    ]
  )
})
