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
      `
      <p>This checked whether <code>true</code> was <code>true</code>.</p>
      <p>The result was <code>true</code>.</p>
    `
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
      `
      <p>This checked whether <code>true</code> was <code>true</code>.</p>
      <p>The result was <code>true</code>.</p>
    `
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
      `
      <p>This checked whether the value returned from <code>ret_true()</code> (<code>true</code>) was <code>true</code>.</p>
      <p>The result was <code>true</code>.</p>
    `
    )
  })
  test('grouped function', () => {
    const { frames } = interpret(`
        function ret_true do
          return true
        end
        if (ret_true()) do
        end
      `)
    const actual = describeFrame(frames[1], [])
    assertHTML(
      actual,
      `
        <p>This checked whether the value returned from <code>ret_true()</code> (<code>true</code>) was <code>true</code>.</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('function with param', () => {
    const { frames } = interpret(`
        function ret_true with value do
          return true
        end
        if ret_true(1) do
        end
      `)
    const actual = describeFrame(frames[1], [])
    assertHTML(
      actual,
      `
        <p>This checked whether the value returned from <code>ret_true(1)</code> (<code>true</code>) was <code>true</code>.</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('function with function param', () => {
    const { frames } = interpret(`
        function ret_true with input do
          return input
        end
        if ret_true(ret_true(true)) do
        end
      `)
    const actual = describeFrame(frames[2], [])
    assertHTML(
      actual,
      `
        <p>This checked whether the value returned from <code>ret_true(true)</code> (<code>true</code>) was <code>true</code>.</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
})
describe('single binary expressions', () => {
  test('literal vs true', () => {
    const { frames } = interpret(`
        if true == true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
        <p>This checked whether <code>true</code> was <code>true</code>.</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('grouped literal vs true', () => {
    const { frames } = interpret(`
        if (true == true) do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
        <p>This checked whether <code>true</code> was <code>true</code>.</p>
        <p>The result was <code>true</code>.</p>
      `
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
      `
        <p>This checked whether the value returned from <code>ret_true()</code> (<code>true</code>) was <code>true</code>.</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('true vs function', () => {
    const { frames } = interpret(`
        function ret_true do
          return true
        end
        if true == ret_true() do
        end
      `)
    const actual = describeFrame(frames[1], [])
    assertHTML(
      actual,
      `
        <p>This checked whether <code>true</code> was equal to the value returned from <code>ret_true()</code> (<code>true</code>).</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('function vs function', () => {
    const { frames } = interpret(`
        function ret_true_1 do
          return true
        end
        function ret_true_2 do
          return true
        end
        if ret_true_1() == ret_true_2() do
        end
      `)
    const actual = describeFrame(frames[2], [])
    assertHTML(
      actual,
      `
        <p>This checked whether the value returned from <code>ret_true_1()</code> (<code>true</code>) was equal to the value returned from <code>ret_true_2()</code> (<code>true</code>).</p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
})
describe('single logical expressions', () => {
  test('boolean and', () => {
    const { frames } = interpret(`
        if true and true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
        <p>
          This checked whether both of these were true:
          <ul>
          <li><code>true</code> was <code>true</code></li>
          <li><code>true</code> was <code>true</code></li>
          </ul>
        </p>
        
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('boolean comparisons and', () => {
    const { frames } = interpret(`
        if true is true and true == true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
        <p>
          This checked whether both of these were true:
          <ul>
            <li><code>true</code> was <code>true</code></li>
            <li><code>true</code> was <code>true</code></li>
          </ul>
        </p>
        
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('functions and', () => {
    const { frames } = interpret(`
        function foo with n1,n2,n3 do
          return true
        end
        function bar do
          return true
        end
        if foo(1,2,3) and bar() do
        end
      `)
    const actual = describeFrame(frames[2], [])
    assertHTML(
      actual,
      `
        <p>
          This checked whether both of these were true:
          <ul>
            <li>the value returned from <code>foo(1, 2, 3)</code> (<code>true</code>) was <code>true</code></li>
            <li>the value returned from <code>bar()</code> (<code>true</code>) was <code>true</code></li>
          </ul>
        </p>
        
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('function comparisons and', () => {
    const { frames } = interpret(`
        function foo with n1,n2,n3 do
          return true
        end
        function bar do
          return true
        end
        if foo(1,2,3) is true and bar() is true do
        end
      `)
    const actual = describeFrame(frames[2], [])
    assertHTML(
      actual,
      `
        <p>
          This checked whether both of these were true:
          <ul>
            <li>the value returned from <code>foo(1, 2, 3)</code> (<code>true</code>) was <code>true</code></li>
            <li>the value returned from <code>bar()</code> (<code>true</code>) was <code>true</code></li>
          </ul>
        </p>
        <p>The result was <code>true</code>.</p>
      `
    )
  })
  test('or', () => {
    const { frames } = interpret(`
        if true is false or true == true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
      <p>
        This checked whether either of these were true:
        <ul>
          <li><code>true</code> was <code>false</code></li>
          <li><code>true</code> was <code>true</code></li>
        </ul>
      </p>
      <p>The result was <code>true</code>.</p>
    `
    )
  })
  test('or short circuit', () => {
    const { error, frames } = interpret(`
        if true or true == true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
      <p>This checked whether <code>true</code> was <code>true</code>. Checking the right side was skipped.</p>
      <p>The result was <code>true</code>.</p>
    `
    )
  })
  test('and short circuit', () => {
    const { error, frames } = interpret(`
        if false and true == true do
        end
      `)
    const actual = describeFrame(frames[0], [])
    assertHTML(
      actual,
      `
      <p>This checked whether <code>false</code> was <code>true</code>. Checking the right side was skipped.</p>
      <p>The result was <code>false</code>.</p>
    `
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
    const actual = describeFrame(frames[3], [])
    assertHTML(
      actual,
      `
      <p>
        This checked whether both of these were true:
        <ul>
          <li>
            both of these were true:
            <ul>
              <li>the value returned from<code>ret_true(1)</code> (<code>true</code>) was <code>true</code></li>
              <li>the value returned from<code>ret_true(2)</code> (<code>true</code>) was <code>true</code></li>
            </ul>
          </li>
          <li>the value returned from<code>ret_true(3)</code> (<code>true</code>) was <code>true</code></li>
        </ul>
      </p>
      <p>The result was <code>true</code>.</p>
    `
    )
  })
})
