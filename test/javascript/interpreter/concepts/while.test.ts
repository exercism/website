import {
  Interpreter,
  interpret,
  evaluateFunction,
} from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe.skip('while', () => {
  test('once', () => {
    const { frames } = interpret(`
        set x to 1
        while (x > 0) do
          change x to x - 1
        end
      `)
    expect(frames).toBeArrayOfSize(4)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: 1 })
    expect(frames[1].status).toBe('SUCCESS')
    expect(frames[1].variables).toMatchObject({ x: 1 })
    expect(frames[2].status).toBe('SUCCESS')
    expect(frames[2].variables).toMatchObject({ x: 0 })
    expect(frames[3].status).toBe('SUCCESS')
    expect(frames[3].variables).toMatchObject({ x: 0 })
  })

  test('multiple times', () => {
    const { frames } = interpret(`
        set x to 3
        while x > 0 do
          change x to x - 1
        end
      `)
    expect(frames).toBeArrayOfSize(8)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: 3 })
    expect(frames[1].status).toBe('SUCCESS')
    expect(frames[1].variables).toMatchObject({ x: 3 })
    expect(frames[2].status).toBe('SUCCESS')
    expect(frames[2].variables).toMatchObject({ x: 2 })
    expect(frames[3].status).toBe('SUCCESS')
    expect(frames[3].variables).toMatchObject({ x: 2 })
    expect(frames[4].status).toBe('SUCCESS')
    expect(frames[4].variables).toMatchObject({ x: 1 })
    expect(frames[5].status).toBe('SUCCESS')
    expect(frames[5].variables).toMatchObject({ x: 1 })
    expect(frames[6].status).toBe('SUCCESS')
    expect(frames[6].variables).toMatchObject({ x: 0 })
    expect(frames[7].status).toBe('SUCCESS')
    expect(frames[7].variables).toMatchObject({ x: 0 })
  })
})
