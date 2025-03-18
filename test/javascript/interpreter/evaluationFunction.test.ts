import { evaluateFunction, Interpreter } from '@/interpreter/interpreter'
import { unwrapJikiObject } from '@/interpreter/jikiObjects'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('evaluateFunction', () => {
  test('first frame', () => {
    const { value, frames, error } = evaluateFunction(
      `
      function move do
        foo()
      end
    `,
      {},
      'move'
    )
    expect(value).toBeUndefined()
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].line).toBe(3)
    expect(frames[0].status).toBe('ERROR')
    expect(frames[0].code).toBe('foo()')
    expect(frames[0].error).not.toBeNull()
    expect(frames[0].error!.category).toBe('RuntimeError')
    expect(frames[0].error!.type).toBe('CouldNotFindFunction')
    expect(frames[0].error!.message).toBe('CouldNotFindFunction: name: foo')
    expect(error).toBeNull()
  })

  test('later frame', () => {
    const code = `
      function move do
        set x to 1
        set y to 2
        foo()
      end
    `
    const { value, frames, error } = evaluateFunction(code, {}, 'move')

    expect(value).toBeUndefined()
    expect(frames).toBeArrayOfSize(3)
    expect(frames[2].line).toBe(5)
    expect(frames[2].status).toBe('ERROR')
    expect(frames[2].code).toBe('foo()')
    expect(frames[2].error).not.toBeNull()
    expect(frames[2].error!.category).toBe('RuntimeError')
    expect(frames[2].error!.type).toBe('CouldNotFindFunction')
    expect(frames[2].error!.message).toBe('CouldNotFindFunction: name: foo')
    expect(error).toBeNull()
  })

  test('missing function', () => {
    const code = `
      function m0ve do
      end
    `
    const { value, frames, error } = evaluateFunction(code, {}, 'move')

    expect(value).toBeUndefined()
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].line).toBe(1)
    expect(frames[0].status).toBe('ERROR')
    expect(frames[0].error).not.toBeNull()
    expect(frames[0].error!.category).toBe('RuntimeError')
    expect(frames[0].error!.type).toBe('ExpectedFunctionNotFound')
    expect(frames[0].error!.message).toBe(
      'ExpectedFunctionNotFound: name: move'
    )
    expect(error).toBeNull()
  })

  test('incorrect args', () => {
    const code = `
      function move with foo do
      end
    `
    const { value, frames, error } = evaluateFunction(code, {}, 'move', 1, 2)

    expect(value).toBeUndefined()
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].line).toBe(1)
    expect(frames[0].status).toBe('ERROR')
    expect(frames[0].error).not.toBeNull()
    expect(frames[0].error!.category).toBe('RuntimeError')
    expect(frames[0].error!.type).toBe('ExpectedFunctionHasWrongArguments')
    expect(frames[0].error!.message).toBe(
      'ExpectedFunctionHasWrongArguments: name: move'
    )
    expect(error).toBeNull()
  })
  test('continue is caught', () => {
    const code = `
      function move do
        continue
      end
    `
    const { value, frames, error } = evaluateFunction(code, {}, 'move')

    expect(value).toBeUndefined()
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].error!.type).toBe('UnexpectedContinueOutsideOfLoop')
    expect(error).toBeNull()
  })
  test('break is caught', () => {
    const code = `
      function move do
        break
      end
    `
    const { value, frames, error } = evaluateFunction(code, {}, 'move')

    expect(value).toBeUndefined()
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].error!.type).toBe('UnexpectedBreakOutsideOfLoop')
    expect(error).toBeNull()
  })
  test('return is caught', () => {
    const code = `
      function move do
      end
      return
    `
    const { value, frames, error } = evaluateFunction(code, {}, 'move')

    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].error!.type).toBe('UnexpectedReturnOutsideOfFunction')
    expect(error).toBeNull()
  })

  test('without arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move do
        return 1
      end
    `,
      {},
      'move'
    )
    expect(value).toBe(1)
    expect(frames).toBeArrayOfSize(1)
    expect(unwrapJikiObject(frames[0].result?.jikiObject)).toBe(1)
  })

  test('with arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move with x, y do
        return x + y
      end
    `,
      {},
      'move',
      1,
      2
    )
    expect(value).toBe(3)
    expect(frames).toBeArrayOfSize(1)
  })

  // TODO: Add when dictionaries and arrays are back
  test.skip('with complex arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move with car, speeds do
        return car["x"] + speeds[1]
      end
    `,
      {},
      'move',
      { x: 2 },
      [4, 5, 6]
    )
    expect(value).toBe(7)
    expect(frames).toBeArrayOfSize(1)
  })
})
