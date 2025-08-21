import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

describe('variable list', () => {
  test('literal', () => {
    const { frames } = interpret(`
    set my_list to [""]
    change my_list[1] to "Jeremy"
    `)
    const actual = describeFrame(frames[1])
    assertHTML(
      actual,
      `<p>This changed the value in the 1st element of the <code>my_list</code> list to <code>"Jeremy"</code>.</p>`,
      [
        `<li>Jiki found the<code>my_list</code>box.</li>`,
        `<li>Jiki removed the existing contents (<code>""</code>) from the 1st slot of the list.</li>`,
        `<li>Jiki put <code>"Jeremy"</code> in the 1st slot of the list.</li>`,
      ]
    )
  })

  test('function', () => {
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(
      `
    set my_list to [""]
    change my_list[1] to get_name()
    `,
      context
    )
    const actual = describeFrame(frames[1])
    assertHTML(
      actual,
      `<p>This changed the value in the 1st element of the <code>my_list</code> list to <code>"Jeremy"</code>.</p>`,
      [
        `<li>Jiki used the<code>get_name()</code>function, which returned<code>\"Jeremy\"</code>.</li>`,
        `<li>Jiki found the<code>my_list</code>box.</li>`,
        `<li>Jiki removed the existing contents (<code>""</code>) from the 1st slot of the list.</li>`,
        `<li>Jiki put <code>"Jeremy"</code> in the 1st slot of the list.</li>`,
      ]
    )
  })
})
