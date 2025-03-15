import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { getNameFunction, assertHTML } from './helpers'

describe('change existing', () => {
  test('literal', () => {
    const { frames } = interpret(`
    set my_dict to {"a": 5}
    change my_dict["a"] to "Jeremy"
    `)
    const actual = describeFrame(frames[1])
    assertHTML(
      actual,
      `<p>This changed the value of the key <code>"a"</code> in the <code>my_dict</code> dictionary to <code>"Jeremy"</code>.</p>`,
      [
        `<li>Jiki found the<code>my_dict</code>box.</li>`,
        `<li>Jiki found the<code>"a"</code>key in the dictionary.</i>`,
        `<li>Jiki updated the corresponding value to be <code>"Jeremy"</code>.</li>`,
      ]
    )
  })

  test('function', () => {
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(
      `
    set my_dict to {"a": 5}
    change my_dict["a"] to get_name()
    `,
      context
    )
    const actual = describeFrame(frames[1])
    assertHTML(
      actual,
      `<p>This changed the value of the key <code>"a"</code> in the <code>my_dict</code> dictionary to <code>"Jeremy"</code>.</p>`,
      [
        `<li>Jiki used the<code>get_name()</code>function, which returned<code>\"Jeremy\"</code>.</li>`,
        `<li>Jiki found the<code>my_dict</code>box.</li>`,
        `<li>Jiki found the<code>"a"</code>key in the dictionary.</i>`,
        `<li>Jiki updated the corresponding value to be <code>"Jeremy"</code>.</li>`,
      ]
    )
  })
})

describe('set new key', () => {
  test('literal', () => {
    const { frames } = interpret(`
    set my_dict to {"a": 5}
    change my_dict["b"] to "Jeremy"
    `)
    const actual = describeFrame(frames[1])
    assertHTML(
      actual,
      `<p>This added a new key/value pair to the<code>my_dict</code>dictionary, with the key of<code>"b"</code>and the value of <code>"Jeremy"</code>.</p>`,
      [
        `<li>Jiki found the<code>my_dict</code>box.</li>`,
        `<li>Jiki checked for the <code>"b"</code>key in the dictionary and saw it was missing.</li>`,
        `<li>Jiki add a new key value pair with the key of<code>"b"</code>and the value of<code>"Jeremy"</code>.</li>`,
      ]
    )
  })

  test('function', () => {
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(
      `
    set my_dict to {"a": 5}
    change my_dict["b"] to get_name()
    `,
      context
    )
    const actual = describeFrame(frames[1])
    assertHTML(
      actual,
      `<p>This added a new key/value pair to the<code>my_dict</code>dictionary, with the key of<code>"b"</code>and the value of <code>"Jeremy"</code>.</p>`,
      [
        `<li>Jiki used the<code>get_name()</code>function, which returned<code>\"Jeremy\"</code>.</li>`,
        `<li>Jiki found the<code>my_dict</code>box.</li>`,
        `<li>Jiki checked for the <code>"b"</code>key in the dictionary and saw it was missing.</li>`,
        `<li>Jiki add a new key value pair with the key of<code>"b"</code>and the value of<code>"Jeremy"</code>.</li>`,
      ]
    )
  })
})
