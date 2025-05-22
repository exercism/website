import { normalizeHtmlText } from '../../../app/javascript/components/bootcamp/common/validateHtml5/normalizeHtmlText'

describe('normalizeHtmlText', () => {
  it('removes HTML comments', () => {
    expect(normalizeHtmlText('<p>Hello</p><!-- comment -->')).toBe(
      '<p>Hello</p>'
    )
  })

  it('removes multiple comments', () => {
    expect(normalizeHtmlText('<!--A--><div>Content</div><!--B-->')).toBe(
      '<div>Content</div>'
    )
  })

  it('removes SVG block', () => {
    expect(normalizeHtmlText('<div><svg><circle /></svg></div>')).toBe(
      '<div></div>'
    )
  })

  it('removes multiline SVG and comments', () => {
    const cleaned = normalizeHtmlText(`
      <div>
        <!-- Comment -->
        <svg>
          <rect />
        </svg>
        Text
      </div>
    `)
    expect(cleaned.replace(/\s+/g, ' ').trim()).toBe('<div> Text </div>')
  })

  it('removes multiple SVGs and comments', () => {
    const result = normalizeHtmlText(`
      <!-- top -->
      <svg><circle /></svg>
      <p>Hello</p>
      <svg><rect /></svg>
      <!-- bottom -->
    `)
    expect(result.replace(/\s+/g, ' ').trim()).toBe('<p>Hello</p>')
  })
})
