import { checkOpeningTagTermination } from '../../../../app/javascript/components/bootcamp/common/validateHtml5/rules/checkOpeningTagTermination'

describe('checkOpeningTagTermination', () => {
  it('passes with fully closed standard tags', () => {
    const html = `
      <div>
        <p>Hello</p>
        <span class="note">Text</span>
      </div>
    `
    expect(() => checkOpeningTagTermination(html)).not.toThrow()
  })

  it('passes with tags that have complex attributes and are properly closed', () => {
    const html = `
      <div style="background: yellow;">
        <p data-x='>'>hello</p>
      </div>
    `
    expect(() => checkOpeningTagTermination(html)).not.toThrow()
  })

  it('fails on unterminated opening tag with attributes', () => {
    const html = `
      <div>
        <p
      </div>
    `
    expect(() => checkOpeningTagTermination(html)).toThrow(
      /Unterminated opening tag: <p/
    )
  })

  it('fails when <div is not closed before the next tag starts', () => {
    const html = `
      <div
      <span>test</span>
    `
    expect(() => checkOpeningTagTermination(html)).toThrow(
      /Unterminated opening tag: <div/
    )
  })

  it('passes when void tags are properly closed', () => {
    const html = `
      <img src="x.jpg">
      <input type="text">
    `
    expect(() => checkOpeningTagTermination(html)).not.toThrow()
  })

  it('fails on multiple malformed tags (only first is thrown)', () => {
    const html = `
      <div>
        <p
        <section
      </div>
    `
    expect(() => checkOpeningTagTermination(html)).toThrow(
      /Unterminated opening tag: <p/
    )
  })
})
