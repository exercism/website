import { checkVoidTagClosure } from '../../../../app/javascript/components/bootcamp/common/validateHtml5/rules/checkVoidTagClosure'

describe('checkVoidTagClosure', () => {
  it('passes with properly closed void tags using >', () => {
    expect(() =>
      checkVoidTagClosure('<img src="x.jpg">\n<input>\n<br>')
    ).not.toThrow()
  })

  it('passes with properly self-closed void tags using />', () => {
    expect(() =>
      checkVoidTagClosure('<img src="x.jpg"/><input/><hr/>')
    ).not.toThrow()
  })

  it('fails on unclosed void tag (missing >)', () => {
    expect(() => checkVoidTagClosure('<img src="x.jpg"\n<input>')).toThrow(
      /Unclosed void tag: <img src="x.jpg"/
    )
  })

  it('fails on void tag with no > across multiple lines', () => {
    expect(() =>
      checkVoidTagClosure(`
        <div>
          <input type="text"
        </div>
      `)
    ).toThrow(/Unclosed void tag: <input type="text"/)
  })

  it('fails on multiple malformed void tags (only first is reported)', () => {
    expect(() => checkVoidTagClosure('<img\n<input\n<link>')).toThrow(
      /Unclosed void tag: <img/
    )
  })

  it('ignores non-void tags (e.g., <div)', () => {
    expect(() => checkVoidTagClosure('<div\n<p>')).not.toThrow()
  })

  it('is case-insensitive (e.g., <IMG)', () => {
    expect(() => checkVoidTagClosure('<IMG src="x"\n<BR>')).toThrow(
      /Unclosed void tag: <IMG/
    )
  })
})
