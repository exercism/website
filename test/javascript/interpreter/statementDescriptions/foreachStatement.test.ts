import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { assertHTML } from './helpers'

describe('empty', () => {
  test('list', () => {
    const { error, frames } = interpret(`
        for each name in [] do
        end
      `)
    const actual = describeFrame(frames[0])
    assertHTML(actual, `<p>The list was empty so this line did nothing.</p>`, [
      `<li>Jiki checked the list, saw it was empty, and decided not to do anything further on this line.</li>`,
    ])
  })
  test('string', () => {
    const { error, frames } = interpret(`
        for each letter in "" do
        end
      `)
    const actual = describeFrame(frames[0])
    assertHTML(
      actual,
      `<p>The string was empty so this line did nothing.</p>`,
      [
        `<li>Jiki checked the string, saw it was empty, and decided not to do anything further on this line.</li>`,
      ]
    )
  })
  test('populated', () => {
    const { error, frames } = interpret(`
        for each name in ["a", "b"] do
        end
      `)
    assertHTML(
      describeFrame(frames[0]),
      `<p>This line started the 1st iteration with the <code>name</code> variable set to <code>"a"</code>.</p>`,
      [
        `<li>Jiki created a new box called <code>name</code>.</li>`,
        `<li>Jiki put <code>"a"</code> in the box, and put it on the shelf, ready to use in the code block.</li>`,
      ]
    )
    assertHTML(
      describeFrame(frames[1]),
      `<p>This line started the 2nd iteration with the <code>name</code> variable set to <code>"b"</code>.</p>`,
      [
        `<li>Jiki created a new box called <code>name</code>.</li>`,
        `<li>Jiki put <code>"b"</code> in the box, and put it on the shelf, ready to use in the code block.</li>`,
      ]
    )
  })
})
