import { interpret } from '@/interpreter/interpreter'
import { describeFrame } from '@/interpreter/frames'
import { assertHTML } from './helpers'

describe('literals', () => {
  test('if true', () => {
    const { error, frames } = interpret(`
        if true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>true</code>so the code block ran.</p>`,
      [
        `<li>The result was<code>true</code>so Jiki decided to run the if block.</li>`,
      ]
    )
  })
  test('if (true)', () => {
    const { frames } = interpret(`
        if (true) do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>true</code>so the code block ran.</p>`,
      [
        `<li>The result was<code>true</code>so Jiki decided to run the if block.</li>`,
      ]
    )
  })
})
describe('function calls', () => {
  test('function', () => {
    const { frames } = interpret(`
        function ret_true do
          return true
        end
        if ret_true() do
        end
      `)
    const actual = describeFrame(frames[1], [])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>true</code>so the code block ran.</p>`,
      [
        `<li>Jiki used the<code>ret_true()</code>function, which returned<code>true</code>.</li>`,
        `<li>The result was<code>true</code>so Jiki decided to run the if block.</li>`,
      ]
    )
  })
})
describe('single binary expressions', () => {
  test('true vs true', () => {
    const { frames } = interpret(`
        if true == true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>true</code>so the code block ran.</p>`,
      [
        `<li>Jiki evaluated<code>true == true</code>and determined it was<code>true</code>.</li>`,
        `<li>The result was<code>true</code>so Jiki decided to run the if block.</li>`,
      ]
    )
  })
  test('function vs true', () => {
    const { frames } = interpret(`
        function ret_true do
          return true
        end
        if ret_true() is true do
        end
      `)
    const actual = describeFrame(frames[1], [])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>true</code>so the code block ran.</p>`,
      [
        `<li>Jiki used the<code>ret_true()</code>function, which returned<code>true</code>.</li>`,
        `<li>Jiki evaluated<code>true is true</code>and determined it was<code>true</code>.</li>`,
        `<li>The result was<code>true</code>so Jiki decided to run the if block.</li>`,
      ]
    )
  })
  test('strings', () => {
    const { frames } = interpret(`
        if " " == "" do
        end
      `)
    const actual = describeFrame(frames[0])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>false</code> so the code block did not run.</p>`,
      [
        `<li>Jiki evaluated <code>" " == ""</code> and determined it was<code>false</code>.</li>`,
        `<li>The result was <code>false</code> so Jiki decided to skip the if block.</li>`,
      ]
    )
  })
})

describe('chained logical expressions', () => {
  test('boolean ands', () => {
    const { frames } = interpret(`
        function ret_true with value do
          return true
        end
        if ret_true(1) and ret_true(2) and ret_true(3) do
        end
      `)
    const actual = describeFrame(frames[3])
    assertHTML(
      actual,
      `<p>The condition evaluated to<code>true</code>so the code block ran.</p>`,
      [
        `<li>Jiki used the<code>ret_true(1)</code>function, which returned<code>true</code>.</li>`,
        `<li>Jiki used the<code>ret_true(2)</code>function, which returned<code>true</code>.</li>`,
        `<li>Jiki evaluated<code>true and true</code>and determined the result was<code>true</code>.</li>`,
        `<li>Jiki used the<code>ret_true(3)</code>function, which returned<code>true</code>.</li>`,
        `<li>Jiki evaluated<code>true and true</code>and determined the result was<code>true</code>.</li>`,
        `<li>The result was<code>true</code>so Jiki decided to run the if block.</li>`,
      ]
    )
  })
})
