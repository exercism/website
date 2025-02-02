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

describe('UnexpectedUncalledFunction', () => {
  test('in a equation with a +', () => {
    const code = 'log get_name + 1'
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(code, context)
    expectFrameToBeError(frames[0], code, 'UnexpectedUncalledFunction')
    expect(frames[0].error!.message).toBe('UnexpectedUncalledFunction')
  })
  test('in a equation with a -', () => {
    const code = 'log get_name - 1'
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

describe('MaxIterationsReached', () => {
  describe('nested loop', () => {
    test('default value', () => {
      const code = `repeat 11 times do
                      repeat 11 times do
                      end
                    end`

      const { frames } = interpret(code)
      const frame = frames[frames.length - 1]
      expectFrameToBeError(frame, 'repeat', 'MaxIterationsReached')
      expect(frame.error!.message).toBe(`MaxIterationsReached: max: 100`)
    })
    test('custom value', () => {
      const code = `repeat 5 times do
                      repeat 11 times do
                      end
                    end`

      const maxIterations = 50
      const { frames } = interpret(code, {
        languageFeatures: { maxTotalLoopIterations: maxIterations },
      })
      const frame = frames[frames.length - 1]
      expectFrameToBeError(frame, 'repeat', 'MaxIterationsReached')
      expect(frame.error!.message).toBe(
        `MaxIterationsReached: max: ${maxIterations}`
      )
    })
  })
  describe('repeat_until_game_over', () => {
    test('default value', () => {
      const code = `repeat_until_game_over do
                    end`

      const { frames } = interpret(code)
      expectFrameToBeError(
        frames[0],
        'repeat_until_game_over',
        'MaxIterationsReached'
      )
      expect(frames[0].error!.message).toBe(`MaxIterationsReached: max: 100`)
    })
    test('custom maxTotalLoopIterations', () => {
      const code = `repeat_until_game_over do
                    end`

      const maxIterations = 50
      const { frames } = interpret(code, {
        languageFeatures: { maxTotalLoopIterations: maxIterations },
      })
      expectFrameToBeError(
        frames[0],
        'repeat_until_game_over',
        'MaxIterationsReached'
      )
      expect(frames[0].error!.message).toBe(
        `MaxIterationsReached: max: ${maxIterations}`
      )
    })
  })
  test('custom maxRepeatUntilGameOverIterations', () => {
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
      `MaxIterationsReached: max: ${maxIterations}`
    )
  })
})
test('InfiniteRecursion', () => {
  const code = `function foo do
                  foo()
                end
                foo()`
  const { frames } = interpret(code)
  expectFrameToBeError(frames[0], 'foo()', 'InfiniteRecursion')
  expect(frames[0].error!.message).toBe('InfiniteRecursion')
})

describe('RepeatCountTooHigh', () => {
  test('default', () => {
    const max = 100
    const { frames } = interpret(`
      repeat ${max + 1} times do
      end
    `)

    expectFrameToBeError(frames[1], `${max + 1}`, 'RepeatCountTooHigh')
    expect(frames[1].error!.message).toBe(
      `RepeatCountTooHigh: count: 101, max: ${max}`
    )
  })
})

describe('CannotStoreNullFromFunction', () => {
  test('setting', () => {
    const max = 100
    const { frames } = interpret(`
      function bar do
      end
      set foo to bar()
    `)

    expectFrameToBeError(
      frames[0],
      `set foo to bar()`,
      'CannotStoreNullFromFunction'
    )
    expect(frames[0].error!.message).toBe(`CannotStoreNullFromFunction`)
  })
  test('changing', () => {
    const max = 100
    const { frames } = interpret(`
      function bar do
      end
      set foo to true
      change foo to bar()
    `)

    expectFrameToBeError(
      frames[1],
      `change foo to bar()`,
      'CannotStoreNullFromFunction'
    )
    expect(frames[1].error!.message).toBe(`CannotStoreNullFromFunction`)
  })
})

describe('ExpressionIsNull', () => {
  test('BinaryExpression: lhs', () => {
    const max = 100
    const { frames } = interpret(`
      function something with meh do\nend
      function bar do\n end
      something(bar() + 1)
    `)

    expectFrameToBeError(frames[0], `something(bar() + 1)`, 'ExpressionIsNull')
    expect(frames[0].error!.message).toBe(`ExpressionIsNull`)
  })

  test('BinaryExpression: rhs', () => {
    const max = 100
    const { frames } = interpret(`
      function something with meh do\nend
      function bar do\n end
      something(1 + bar())
    `)

    expectFrameToBeError(frames[0], `something(1 + bar())`, 'ExpressionIsNull')
    expect(frames[0].error!.message).toBe(`ExpressionIsNull`)
  })
})

describe('OperandMustBeNumber', () => {
  test('1 - "a"', () => {
    const code = 'log 1 - "a"'
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'OperandMustBeNumber')
    expect(frames[0].error!.message).toBe('OperandMustBeNumber: value: "a"')
  })
  test('1 / true', () => {
    const code = 'log 1 / true'
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'OperandMustBeNumber')
    expect(frames[0].error!.message).toBe('OperandMustBeNumber: value: true')
  })
  test('false - 1', () => {
    const code = 'log false - 1'
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'OperandMustBeNumber')
    expect(frames[0].error!.message).toBe('OperandMustBeNumber: value: false')
  })
  test('1 * false', () => {
    const code = 'log 1 * false'
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'OperandMustBeNumber')
    expect(frames[0].error!.message).toBe('OperandMustBeNumber: value: false')
  })
  test('1 * getName()', () => {
    const code = 'log 1 * get_name()'
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(code, context)
    expectFrameToBeError(frames[0], code, 'OperandMustBeNumber')
    expect(frames[0].error!.message).toBe(
      'OperandMustBeNumber: value: "Jeremy"'
    )
  })
})

describe('OperandMustBeBoolean', () => {
  test('not number', () => {
    const { frames } = interpret(`log not 1`)

    expectFrameToBeError(frames[0], `log not 1`, 'OperandMustBeBoolean')
    expect(frames[0].error!.message).toBe(`OperandMustBeBoolean: value: 1`)
  })
  test('bang string', () => {
    const { frames } = interpret(`log !"foo"`)

    expectFrameToBeError(frames[0], `log !"foo"`, 'OperandMustBeBoolean')
    expect(frames[0].error!.message).toBe(`OperandMustBeBoolean: value: "foo"`)
  })

  test('strings in conditionals', () => {
    const code = `if "foo" do 
                  end`
    const { error, frames } = interpret(code)

    expectFrameToBeError(frames[0], code, 'OperandMustBeBoolean')
    expect(frames[0].error!.message).toBe(`OperandMustBeBoolean: value: "foo"`)
  })

  test('function call in conditionals', () => {
    const code = `function ret_str do
                    return "foo"
                  end
                  if ret_str() do 
                  end`
    const { error, frames } = interpret(code)

    expectFrameToBeError(frames[1], 'ret_str()', 'OperandMustBeBoolean')
    expect(frames[1].error!.message).toBe(`OperandMustBeBoolean: value: "foo"`)
  })
})

describe('ForeachNotIterable', () => {
  test('number', () => {
    const code = `for each num in 1 do
    end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], '1', 'ForeachNotIterable')
    expect(frames[0].error!.message).toBe('ForeachNotIterable: value: 1')
  })
  test('boolean', () => {
    const code = `for each num in true do
    end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], 'true', 'ForeachNotIterable')
    expect(frames[0].error!.message).toBe('ForeachNotIterable: value: true')
  })
  test('function that returns number', () => {
    const code = `
      function ret_5 do
        return 5
      end
      for each num in ret_5() do
      end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[1], 'ret_5()', 'ForeachNotIterable')
    expect(frames[1].error!.message).toBe('ForeachNotIterable: value: 5')
  })
})
