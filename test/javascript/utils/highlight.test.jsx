import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import hljs from 'highlight.js'
import {
  highlightAll,
  useHighlighting,
} from '../../../app/javascript/utils/highlight'

test('highlightAll() highlights code snippets', () => {
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
  highlightAll(actual)

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('highlightAll() highlights code snippets with line numbers', () => {
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

  highlightAll(actual)

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('highlightAll() highlights multiline blocks correctly', () => {
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
  highlightAll(actual)

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('useHighlighting() adds highlighting to components', () => {
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

  expect(screen.getByText('class')).toHaveAttribute('class', 'hljs-keyword')
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
])('registers and highlights %s', (language, code) => {
  expect(hljs.getLanguage(language)).toBeDefined()

  const actual = document.createElement('div')
  actual.innerHTML = `<pre><code class="language-${language}"></code></pre>`
  actual.querySelector('code').textContent = code
  highlightAll(actual)

  expect(actual.querySelector('code').innerHTML).toContain('hljs-')
})

function removeFormatting(html) {
  return html.replace(/\n| /g, '')
}
