import fs from 'fs'
import path from 'path'
import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import hljs from 'highlight.js/lib/core'
import {
  highlightAll,
  highlightAllAlways,
  useHighlighting,
} from '../../../app/javascript/utils/highlight'
import { grammars } from '../../../app/javascript/utils/highlight-grammars'

test('highlightAll() highlights code snippets', async () => {
  const expected = document.createElement('div')
  expected.innerHTML = `
    <pre>
      <code class="ruby hljs language-ruby" data-highlighted="true">
        <span class="hljs-keyword">class</span>
        <span class="hljs-title class_">Dog</span>
        <span class="hljs-keyword">end</span>
      </code>
    </pre>
  `

  const actual = document.createElement('div')
  actual.innerHTML = `
    <pre>
      <code class="ruby">
        class Dog
        end
      </code>
    </pre>
  `
  await highlightAll(actual)

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('highlightAll() highlights code snippets with line numbers', async () => {
  const expected = document.createElement('div')
  expected.innerHTML = `
    <pre>
      <code class="ruby hljs language-ruby" data-highlight-line-numbers data-highlight-line-number-start="2" data-highlighted="true">
        <ul>
          <li>
            <div class="idx">2</div>
            <div class="loc">
              <span class="hljs-keyword">class</span>
              <span class="hljs-title class_">Dog</span>
            </div>
          </li>
          <li>
            <div class="idx">3</div>
            <div class="loc">
              <span class="hljs-keyword">end</span>
            </div>
          </li>
        </ul>
      </code>
    </pre>
  `

  const actual = document.createElement('div')
  actual.innerHTML = `
    <pre>
      <code class="ruby" data-highlight-line-numbers data-highlight-line-number-start="2">class Dog
        end</code>
    </pre>
  `

  await highlightAll(actual)

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('highlightAll() highlights multiline blocks correctly', async () => {
  const expected = document.createElement('div')
  expected.innerHTML = `
    <pre>
      <code class="javascript hljs language-javascript" data-highlight-line-numbers data-highlighted="true">
        <ul>
          <li>
            <div class="idx">1</div>
            <div class="loc">
              <span class="hljs-comment">
                <span class="hljs-comment">/*</span>
              </span>
            </td>
          </li>
          <li>
            <div class="idx">2</div>
            <div class="loc">
              <span class="hljs-comment">Multi</span>
            </div>
          </li>
          <li>
            <div class="idx">3</div>
            <div class="loc">
              <span class="hljs-comment">line comments</span>
            </div>
          </li>
          <li>
            <div class="idx">4</div>
            <div class="loc">
              <span class="hljs-comment">*/</span>
            </div>
          </li>
        </ul>
      </code>
    </pre>
  `

  const actual = document.createElement('div')
  actual.innerHTML = `
    <pre>
      <code class="javascript" data-highlight-line-numbers>/*
          Multi
          line comments
        */</code>
    </pre>
  `
  await highlightAll(actual)

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('useHighlighting() adds highlighting to components', async () => {
  const Component = () => {
    const parentRef = useHighlighting()

    return (
      <div ref={parentRef}>
        <pre>
          <code className="ruby">class Dog end</code>
        </pre>
      </div>
    )
  }
  render(<Component />)

  expect(await screen.findByText('class')).toHaveAttribute(
    'class',
    'hljs-keyword'
  )
})

test.each([
  ['odin', 'main :: proc() {}'],
  ['sqlite', 'SELECT * FROM users;'],
  ['euphoria', 'integer x = 1'],
  ['factor', ': square ( x -- y ) dup * ;'],
  ['8th', ': square dup n:* ;'],
  ['roc', 'main = Stdout.line! "Hi"'],
  ['yamlscript', '!YS-v0\ndefn main(): say("Hi")'],
  ['raku', 'my $x = 1; say $x;'],
  ['cairo', 'fn main() -> felt252 { 1 }'],
  ['vlang', 'fn main() { println("Hi") }'],
  ['purescript', 'main = log "Hi"'],
  ['unison', 'square x = x * x'],
  ['idris', 'square : Int -> Int'],
  ['cfml', 'component { function f() { return 1; } }'],
  ['racket', '(define (square x) (* x x))'],
  ['lfe', '(defun square (x) (* x x))'],
  ['rescript', 'let x = 1'],
])('loads and highlights %s', async (language, code) => {
  const actual = codeBlock(language, code)
  await highlightAll(actual)

  expect(hljs.getLanguage(language)).toBeDefined()
  expect(actual.querySelector('code').innerHTML).toContain('hljs-')
})

test('highlightAll() resolves aliases to their grammar', async () => {
  const actual = codeBlock('golang', 'func main() {}')
  await highlightAll(actual)

  expect(hljs.getLanguage('go')).toBeDefined()
  expect(actual.querySelector('code').innerHTML).toContain('hljs-keyword')
})

test('highlightAll() reads a bare class name as the language', async () => {
  const actual = document.createElement('div')
  actual.innerHTML =
    '<pre><code class="elixir">defmodule Foo do end</code></pre>'
  await highlightAll(actual)

  expect(actual.querySelector('code').innerHTML).toContain('hljs-keyword')
})

test('highlightAll() imports each grammar only once', async () => {
  const load = jest.spyOn(grammars.haskell, 'load')

  const first = codeBlock('haskell', 'main = putStrLn "Hi"')
  const second = codeBlock('hs', 'main = putStrLn "Hi"')
  await Promise.all([highlightAll(first), highlightAll(second)])
  await highlightAll(codeBlock('haskell', 'x = 1'))

  expect(load).toHaveBeenCalledTimes(1)
  expect(first.querySelector('code').innerHTML).toContain('hljs-')
  expect(second.querySelector('code').innerHTML).toContain('hljs-')
})

test('highlightAll() highlights synchronously once a grammar is loaded', async () => {
  await highlightAll(codeBlock('python', 'def f(): pass'))

  const actual = codeBlock('python', 'def g(): pass')
  highlightAll(actual)

  expect(actual.querySelector('code').innerHTML).toContain('hljs-keyword')
})

test('highlightAll() loads the grammars a grammar embeds', async () => {
  expect(hljs.getLanguage('julia')).toBeUndefined()

  const actual = codeBlock('julia-repl', 'julia> function f() end')
  await highlightAll(actual)

  expect(hljs.getLanguage('julia')).toBeDefined()
  expect(actual.querySelector('code').innerHTML).toContain(
    '<span class="hljs-keyword">function</span>'
  )
})

test.each(['plaintext', 'not-a-language'])(
  'highlightAll() leaves %s as plain text',
  async (language) => {
    const log = jest.spyOn(console, 'log').mockImplementation(() => {})
    const actual = codeBlock(language, 'def f(): pass')
    await highlightAll(actual)

    const code = actual.querySelector('code')
    expect(code.textContent).toEqual('def f(): pass')
    expect(code.innerHTML).not.toContain('hljs-')
    expect(code.dataset.highlighted).toEqual('true')
    log.mockRestore()
  }
)

test('highlightAllAlways() highlights a block again', async () => {
  const actual = codeBlock('ruby', 'class Dog end')
  await highlightAll(actual)
  actual.querySelector('code').textContent = 'module Cat end'

  await highlightAllAlways(actual)

  expect(actual.querySelector('code').innerHTML).toContain(
    '<span class="hljs-keyword">module</span>'
  )
})

test('every grammar shipped with highlight.js can be loaded', () => {
  const builtIn = fs
    .readdirSync(
      path.dirname(require.resolve('highlight.js/lib/languages/ruby'))
    )
    .filter((file) => file.endsWith('.js') && !file.endsWith('.js.js'))
    .map((file) => file.replace(/\.js$/, ''))

  // If this fails after upgrading highlight.js, run `yarn highlight-grammars`.
  expect(builtIn.filter((name) => !(name in grammars))).toEqual([])
})

function codeBlock(language, code) {
  const element = document.createElement('div')
  element.innerHTML = `<pre><code class="language-${language}"></code></pre>`
  element.querySelector('code').textContent = code
  return element
}

function removeFormatting(html) {
  return html.replace(/\n| /g, '')
}
