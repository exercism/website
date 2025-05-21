import { checkNesting } from '../../../../app/javascript/components/bootcamp/common/validateHtml5/rules/checkNesting'

describe('checkNesting', () => {
  it('passes with properly nested tags', () => {
    expect(() => checkNesting('<div><p>Hello</p></div>')).not.toThrow()
  })

  it('passes with void tags inside nested tags', () => {
    expect(() =>
      checkNesting('<div><img src="x.jpg"><br><input></div>')
    ).not.toThrow()
  })

  it('passes with custom elements that are properly nested', () => {
    expect(() =>
      checkNesting('<my-box><span>Text</span></my-box>')
    ).not.toThrow()
  })

  it('throws on extra closing tag', () => {
    expect(() => checkNesting('<p>Hello</p></p>')).toThrow(
      'Extra closing tag: </p>'
    )
  })

  it('throws on mismatched tags', () => {
    expect(() => checkNesting('<div><span>Oops</div></span>')).toThrow(
      'Mismatched tags: <span> closed by </div>'
    )
  })

  it('throws on unclosed tag', () => {
    expect(() => checkNesting('<section><article></section>')).toThrow(
      'Mismatched tags: <article> closed by </section>'
    )
  })

  it('throws on multiple unclosed tags', () => {
    expect(() => checkNesting('<ul><li><li></ul>')).toThrow(
      'Mismatched tags: <li> closed by </ul>'
    )
  })

  it('throws on reversed nesting order', () => {
    expect(() => checkNesting('<b><i>text</b></i>')).toThrow(
      'Mismatched tags: <i> closed by </b>'
    )
  })

  it('ignores properly used void elements without closing slash', () => {
    expect(() => checkNesting('<hr><br><input type="text">')).not.toThrow()
  })

  it('ignores properly used self-closing void elements', () => {
    expect(() => checkNesting('<img src="x.jpg"/><input/>')).not.toThrow()
  })
})
