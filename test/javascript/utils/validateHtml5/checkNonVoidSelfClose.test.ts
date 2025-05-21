import { checkNonVoidSelfClose } from '../../../../app/javascript/components/bootcamp/common/validateHtml5/rules/checkNonVoidSelfClose'

describe('checkNonVoidSelfClose', () => {
  it('allows valid void elements that self-close', () => {
    const html = `
      <img src="x.jpg"/>
      <br/>
      <input type="text" />
    `
    expect(() => checkNonVoidSelfClose(html)).not.toThrow()
  })

  it('throws on self-closing non-void tag: <p/>', () => {
    const html = `
      <div>
        <p/>
      </div>
    `
    expect(() => checkNonVoidSelfClose(html)).toThrow(
      /Non-void element <p\/> cannot be self-closed/
    )
  })

  it('throws on self-closing non-void tag with attributes', () => {
    const html = `
      <div class="container"/>
    `
    expect(() => checkNonVoidSelfClose(html)).toThrow(
      /Non-void element <div\/> cannot be self-closed/
    )
  })

  it('throws only on the first offending non-void self-closed tag', () => {
    const html = `
      <p/>
      <section/>
    `
    expect(() => checkNonVoidSelfClose(html)).toThrow(
      /Non-void element <p\/> cannot be self-closed/
    )
  })

  it('ignores normal opening and closing tags', () => {
    const html = `
      <div>
        <p>Hello</p>
        <span>Text</span>
      </div>
    `
    expect(() => checkNonVoidSelfClose(html)).not.toThrow()
  })
})
