import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import {
  getNameFunction,
  assertHTML,
  contextToDescriptionContext,
} from './helpers'

test('naked', () => {
  const { frames } = interpret(`
    function fn do
      return
    end
    fn()
  `)
  const actual = describeFrame(frames[0])
  assertHTML(
    actual,
    `<p>This ended the function. No further code was run in the function.</p>`,
    [`<li>Jiki cleared up and left the function.</li>`]
  )
})

test('with literal', () => {
  const { frames } = interpret(`
    function fn do
      return 5
    end
    fn()
  `)
  const actual = describeFrame(frames[0])
  assertHTML(
    actual,
    `<p>This returned <code>5</code> and ended the function. No further code was run in the function.</p>`,
    [
      `<li>Jiki put <code>5</code> in the return chute.</li>`,
      `<li>Jiki cleared up and left the function.</li>`,
    ]
  )
})

test('with function', () => {
  const context = { externalFunctions: [getNameFunction] }
  const descContext = contextToDescriptionContext(context)
  const { frames } = interpret(
    `
    function fn do
      return get_name()
    end
    fn()
  `,
    context
  )
  const actual = describeFrame(frames[0], descContext)
  assertHTML(
    actual,
    `<p>This returned <code>"Jeremy"</code> and ended the function. No further code was run in the function.</p>`,
    [
      `<li>Jiki used the<code>get_name()</code>function, which always returns the string Jeremy. It returned<code>\"Jeremy\"</code>.</li>`,
      `<li>Jiki put<code>\"Jeremy\"</code>in the return chute.</li>`,
      `<li>Jiki cleared up and left the function.</li>`,
    ]
  )
})
