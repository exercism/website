import { interpret } from '@/interpreter/interpreter'
import { Location, Span } from '@/interpreter/location'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

const location = new Location(0, new Span(0, 0), new Span(0, 0))
const getNameFunction = {
  name: 'get_name',
  func: (_interpreter: any) => {
    return 'Jeremy'
  },
  description: '',
}

function expectFrameToBeError(frame, code, type) {
  expect(frame.code).toBe(code)
  expect(frame.status).toBe('ERROR')
  expect(frame.error).not.toBeNull()
  expect(frame.error!.category).toBe('RuntimeError')
  expect(frame.error!.type).toBe(type)
}

describe('Runtime errors', () => {
  describe('OperandsMustBeNumbers', () => {
    test('1 - "a"', () => {
      const code = '1 - "a"'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: -, side: right, value: `&quot;a&quot;`'
      )
    })
    test('1 / true', () => {
      const code = '1 / true'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: &#x2F;, side: right, value: `true`'
      )
    })
    test('false - 1', () => {
      const code = 'false - 1'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: -, side: left, value: `false`'
      )
    })
    test('1 * false', () => {
      const code = '1 * false'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: *, side: right, value: `false`'
      )
    })
    test('1 * getName()', () => {
      const code = '1 * get_name()'
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret(code, context)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: *, side: right, value: `&quot;Jeremy&quot;`'
      )
    })
  })

  describe('UnexpectedUncalledFunction', () => {
    test('in a equation with a +', () => {
      const code = 'get_name + 1'
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret(code, context)
      expectFrameToBeError(frames[0], code, 'UnexpectedUncalledFunction')
      expect(frames[0].error!.message).toBe('UnexpectedUncalledFunction')
    })
    test('in a equation with a -', () => {
      const code = 'get_name - 1'
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret(code, context)
      expectFrameToBeError(frames[0], code, 'UnexpectedUncalledFunction')
      expect(frames[0].error!.message).toBe('UnexpectedUncalledFunction')
    })
  })
})
