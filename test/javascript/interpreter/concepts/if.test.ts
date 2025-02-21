import { interpret } from '@/interpreter/interpreter'
import { unwrapJikiObject } from '@/interpreter/jikiObjects'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('if', () => {
  test('true means run block', () => {
    const { frames } = interpret(`
      if true do
        set x to 2
      end
    `)
    expect(frames).toBeArrayOfSize(2)
    expect(frames[0].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[0].variables)).toBeEmpty()
    expect(frames[1].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[1].variables)).toMatchObject({ x: 2 })
  })

  test('false means no block', () => {
    const { frames } = interpret(`
      if false do
        set x to 2
      end
    `)
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[0].variables)).toBeEmpty()
  })

  test('compare bools', () => {
    const { frames } = interpret(`
      if true is true do
        set x to 2
      end
    `)
    expect(frames).toBeArrayOfSize(2)
    expect(frames[0].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[0].variables)).toBeEmpty()
    expect(frames[1].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[1].variables)).toMatchObject({ x: 2 })
  })

  test('with else', () => {
    const { frames } = interpret(`
      if true is false do
        set x to 2
      else do
        set x to 3
      end
    `)
    expect(frames).toBeArrayOfSize(2)
    expect(frames[0].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[0].variables)).toBeEmpty()
    expect(frames[1].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[1].variables)).toMatchObject({ x: 3 })
  })

  test('stacked', () => {
    const { frames } = interpret(`
      if true is false do
        set x to 2
      else if true is true do
        set x to 3
      else do
        set x to 4
      end
    `)
    expect(frames).toBeArrayOfSize(3)
    expect(frames[0].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[0].variables)).toBeEmpty()
    expect(frames[1].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[1].variables)).toBeEmpty()
    expect(frames[2].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[2].variables)).toMatchObject({ x: 3 })
  })
  test('nested if', () => {
    const { error, frames } = interpret(`
      set x to 1
      if true is true do
        change x to 2
        if true is true do
          change x to 3
        end
      end
    `)
    expect(error).toBeNull()
    expect(frames).toBeArrayOfSize(5)
    frames.forEach((frame) => {
      expect(frame.status).toBe('SUCCESS')
    })
  })
  test('nested if/else', () => {
    const { error, frames } = interpret(`
      set x to 1
      if true is true do
        change x to 2
        if true is true do
          change x to 3
        end
      else do
        change x to 4
      end
    `)
    expect(error).toBeNull()
    expect(frames).toBeArrayOfSize(5)
    frames.forEach((frame) => {
      expect(frame.status).toBe('SUCCESS')
    })
  })
})
