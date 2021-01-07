import { highlight } from '../../../app/javascript/utils/highlight'

test('highlight() highlights code snippets', () => {
  const expected = document.createElement('div')
  expected.innerHTML = `
    <table>
      <tr>
        <td>1</td>
        <td>
          <span class="hljs-class">
            <span class="hljs-keyword">class</span>
            <span class="hljs-title">Dog</span>
          </span>
        </td>
      </tr>
      <tr>
        <td>2</td>
        <td>
          <span class="hljs-keyword">end</span>
        </td>
      </tr>
    </table>
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
    <table>
      <tbody>
        <tr>
          <td>1</td>
          <td>
            <span class="hljs-comment">
              <span class="hljs-comment">/*</span>
            </span>
          </td>
        </tr>
        <tr>
          <td>2</td>
          <td><span class="hljs-comment">Multi</span></td>
        </tr>
        <tr>
          <td>3</td>
          <td><span class="hljs-comment">line comments</span></td>
        </tr>
        <tr>
          <td>4</td>
          <td><span class="hljs-comment">*/</span></td>
        </tr>
      </tbody>
    </table>
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
