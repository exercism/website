import { highlight } from '../../../app/javascript/utils/highlight'

test('highlight() highlights code snippets', () => {
  const expected = document.createElement('div')
  expected.innerHTML = `
    <ul>
      <li>
        <div class="idx">1</div>
        <div class="loc">
          <span class="hljs-class">
            <span class="hljs-keyword">class</span>
            <span class="hljs-title">Dog</span>
          </span>
        </div>
      </li>
      <li>
        <div class="idx">2</div>
        <div class="loc">
          <span class="hljs-keyword">end</span>
        </div>
      </li>
    </ul>
    `

  const actual = document.createElement('div')
  actual.innerHTML = highlight('ruby', 'class Dog\nend')

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

test('highlight() highlights multiline blocks correctly', () => {
  const expected = document.createElement('div')
  expected.innerHTML = `
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
  `

  const actual = document.createElement('div')
  actual.innerHTML = highlight(
    'javascript',
    `
      /*
        Multi
        line comments
      */
    `
  )

  expect(removeFormatting(actual.innerHTML)).toEqual(
    removeFormatting(expected.innerHTML)
  )
})

function removeFormatting(html) {
  return html.replace(/\n| /g, '')
}
