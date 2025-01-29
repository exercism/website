import { RuntimeError, RuntimeErrorType } from '@/interpreter/error'
import { Frame } from '@/interpreter/frames'
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

function expectFrameToBeError(
  frame: Frame,
  code: string,
  type: RuntimeErrorType
) {
  expect(frame.code.trim()).toBe(code.trim())
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
        'OperandsMustBeNumbers: operator: -, side: right, value: "a"'
      )
    })
    test('1 / true', () => {
      const code = '1 / true'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: /, side: right, value: true'
      )
    })
    test('false - 1', () => {
      const code = 'false - 1'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: -, side: left, value: false'
      )
    })
    test('1 * false', () => {
      const code = '1 * false'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: *, side: right, value: false'
      )
    })
    test('1 * getName()', () => {
      const code = '1 * get_name()'
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret(code, context)
      expectFrameToBeError(frames[0], code, 'OperandsMustBeNumbers')
      expect(frames[0].error!.message).toBe(
        'OperandsMustBeNumbers: operator: *, side: right, value: "Jeremy"'
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
  describe('FunctionAlreadyDeclared', () => {
    test('basic', () => {
      const code = 'set get_name to 5'
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret(code, context)
      expectFrameToBeError(frames[0], code, 'FunctionAlreadyDeclared')
      expect(frames[0].error!.message).toBe(
        'FunctionAlreadyDeclared: name: get_name'
      )
    })
  })
  describe('UnexpectedChangeOfFunction', () => {
    test('basic', () => {
      const code = 'change get_name to 5'
      const context = { externalFunctions: [getNameFunction] }
      const { frames } = interpret(code, context)
      expectFrameToBeError(frames[0], code, 'UnexpectedChangeOfFunction')
      expect(frames[0].error!.message).toBe(
        'UnexpectedChangeOfFunction: name: get_name'
      )
    })
  })
  describe('UnexpectedReturnOutsideOfFunction', () => {
    test('with result', () => {
      const code = 'return 1'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'UnexpectedReturnOutsideOfFunction')
      expect(frames[0].error!.message).toBe('UnexpectedReturnOutsideOfFunction')
    })
    test('without result', () => {
      const code = 'return'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'UnexpectedReturnOutsideOfFunction')
      expect(frames[0].error!.message).toBe('UnexpectedReturnOutsideOfFunction')
    })
  })
  describe('VariableAlreadyDeclared', () => {
    test('basic', () => {
      const code = `set x to 5
                    set x to 6`
      const { frames } = interpret(code)
      expectFrameToBeError(frames[1], 'set x to 6', 'VariableAlreadyDeclared')
      expect(frames[1].error!.message).toBe('VariableAlreadyDeclared: name: x')
    })
  })

  describe('VariableNotDeclared', () => {
    test('basic', () => {
      const code = 'change x to 6'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'VariableNotDeclared')
      expect(frames[0].error!.message).toBe('VariableNotDeclared: name: x')
    })
  })
  describe('VariableNotAccessibleInFunction', () => {
    test('basic', () => {
      const code = `set x to 6
                    function foo do
                      change x to 7
                    end
                    foo()`
      const { frames, error } = interpret(code)
      expectFrameToBeError(
        frames[1],
        'change x to 7',
        'VariableNotAccessibleInFunction'
      )
      expect(frames[1].error!.message).toBe(
        'VariableNotAccessibleInFunction: name: x'
      )
    })
  })
  test('MaxIterationsReached', () => {
    const code = `repeat_until_game_over do
                  end`

    const maxIterations = 50
    const { frames } = interpret(code, {
      languageFeatures: { maxRepeatUntilGameOverIterations: maxIterations },
    })
    expectFrameToBeError(
      frames[0],
      'repeat_until_game_over',
      'MaxIterationsReached'
    )
    expect(frames[0].error!.message).toBe(
      `MaxIterationsReached: maxIterations: ${maxIterations}`
    )
  })
})
