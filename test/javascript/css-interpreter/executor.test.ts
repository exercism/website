import { interpret } from '@/css-interpreter/interpreter'
import { changeLanguage } from '@/css-interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('basic', () => {
  test('one div one property', () => {
    const { frames } = interpret('div { color: red }')
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].animations).toBeArrayOfSize(1)
    expect(frames[0].animations[0].selector).toBe('div')
    expect(frames[0].animations[0].property).toBe('color')
    expect(frames[0].animations[0].value).toBe('red')
    expect
  })

  test('nested forks two properties', () => {
    const { frames } = interpret(`
      .blue {
        .red, .green {
          color: red;
          background:blue
        }
      }
    `)
    expect(frames).toBeArrayOfSize(2)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].animations).toBeArrayOfSize(2)
    expect(frames[0].animations[0].selector).toBe('.blue .red')
    expect(frames[0].animations[0].property).toBe('color')
    expect(frames[0].animations[0].value).toBe('red')
    expect(frames[0].animations[1].selector).toBe('.blue .green')
    expect(frames[0].animations[1].property).toBe('color')
    expect(frames[0].animations[1].value).toBe('red')
    expect(frames[1].animations[0].selector).toBe('.blue .red')
    expect(frames[1].animations[0].property).toBe('background')
    expect(frames[1].animations[0].value).toBe('blue')
    expect(frames[1].animations[1].selector).toBe('.blue .green')
    expect(frames[1].animations[1].property).toBe('background')
    expect(frames[1].animations[1].value).toBe('blue')
  })
})
