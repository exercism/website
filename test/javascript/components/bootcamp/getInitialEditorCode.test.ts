import { getInitialEditorCode } from '@/components/bootcamp/CSSExercisePage/hooks/getInitialEditorCode'
describe('getInitialEditorCode', () => {
  const baseStub = {
    stub: {
      html: '<div>Hello</div>',
      css: 'div { color: red; }',
    },
    code: undefined,
    defaultReadonlyRanges: {
      html: [{ start: 0, end: 5 }],
      css: [{ start: 0, end: 10 }],
    },
  }

  it('returns fallback code when code.code is undefined', () => {
    const result = getInitialEditorCode(baseStub)
    expect(result).toMatchObject({
      htmlEditorContent: baseStub.stub.html,
      cssEditorContent: baseStub.stub.css,
      readonlyRanges: baseStub.defaultReadonlyRanges,
    })
    expect(typeof result.storedAt).toBe('string')
  })

  it('returns fallback code and logs error when code.code is invalid JSON', () => {
    const invalidCode = { ...baseStub, code: '{ invalid JSON' }
    console.error = jest.fn()
    const result = getInitialEditorCode(invalidCode)
    expect(result).toMatchObject({
      htmlEditorContent: baseStub.stub.html,
      cssEditorContent: baseStub.stub.css,
      readonlyRanges: baseStub.defaultReadonlyRanges,
    })
    expect(console.error).toHaveBeenCalled()
  })

  it('uses stub html/css if parsed code is missing both', () => {
    const input = {
      ...baseStub,
      code: JSON.stringify({}),
    }
    const result = getInitialEditorCode(input)
    expect(result.htmlEditorContent).toBe(baseStub.stub.html)
    expect(result.cssEditorContent).toBe(baseStub.stub.css)
  })

  it('uses stub html if parsed html is empty', () => {
    const input = {
      ...baseStub,
      code: JSON.stringify({ html: '' }),
    }
    const result = getInitialEditorCode(input)
    expect(result.htmlEditorContent).toBe(baseStub.stub.html)
  })

  it('uses stub css if parsed css is empty', () => {
    const input = {
      ...baseStub,
      code: JSON.stringify({ css: '' }),
    }
    const result = getInitialEditorCode(input)
    expect(result.cssEditorContent).toBe(baseStub.stub.css)
  })

  it('trims html/css content if provided in parsed code', () => {
    const input = {
      ...baseStub,
      code: JSON.stringify({
        html: '  <p>Hi</p>  ',
        css: '  p { color: blue; }  ',
      }),
    }
    const result = getInitialEditorCode(input)
    expect(result.htmlEditorContent).toBe('<p>Hi</p>')
    expect(result.cssEditorContent).toBe('p { color: blue; }')
  })

  it('handles missing defaultReadonlyRanges', () => {
    const input = {
      stub: baseStub.stub,
      code: undefined,
      defaultReadonlyRanges: undefined,
    }
    const result = getInitialEditorCode(input)
    expect(result.readonlyRanges).toEqual({ html: [], css: [] })
  })

  it('handles partially defined defaultReadonlyRanges', () => {
    const input = {
      stub: baseStub.stub,
      code: undefined,
      defaultReadonlyRanges: {
        html: [{ start: 0, end: 3 }],
        // css is undefined
      },
    }
    const result = getInitialEditorCode(input)
    expect(result.readonlyRanges).toEqual({
      html: [{ start: 0, end: 3 }],
      css: [],
    })
  })
})
