import { RuntimeErrorType } from '@/interpreter/error'
import { Frame } from '@/interpreter/frames'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { Location, Span } from '@/interpreter/location'
import { changeLanguage } from '@/interpreter/translator'
import * as Jiki from '@/interpreter/jikiObjects'

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
    return new Jiki.String('Jeremy')
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
    expect(frames[0].error!.message).toBe(
      'UnexpectedUncalledFunction: name: get_name'
    )
  })
  test('in a equation with a -', () => {
    const code = 'log get_name - 1'
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(code, context)
    expectFrameToBeError(frames[0], code, 'UnexpectedUncalledFunction')
    expect(frames[0].error!.message).toBe(
      'UnexpectedUncalledFunction: name: get_name'
    )
  })
  test('in other function', () => {
    const code = `
        function move with x do
          return 1
        end

        log move(move)
      `
    const { error, frames } = interpret(code)
    expectFrameToBeError(
      frames[0],
      `log move(move)`,
      'UnexpectedUncalledFunction'
    )
    expect(frames[0].error!.message).toBe(
      'UnexpectedUncalledFunction: name: move'
    )
  })

  test('with left parenthesis', () => {
    const code = `
        function move do
          return 1
        end

        log move
      `
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], `log move`, 'UnexpectedUncalledFunction')
    expect(frames[0].error!.message).toBe(
      'UnexpectedUncalledFunction: name: move'
    )
  })
})
describe('FunctionAlreadyDeclared', () => {
  test('variable name', () => {
    const code = 'set get_name to 5'
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(code, context)
    expectFrameToBeError(frames[0], code, 'FunctionAlreadyDeclared')
    expect(frames[0].error!.message).toBe(
      'FunctionAlreadyDeclared: name: get_name'
    )
  })
  test('external function', () => {
    const code = `function get_name do
    end`
    const context = { externalFunctions: [getNameFunction] }
    const { frames } = interpret(code, context)
    expectFrameToBeError(frames[0], 'get_name', 'FunctionAlreadyDeclared')
    expect(frames[0].error!.message).toBe(
      'FunctionAlreadyDeclared: name: get_name'
    )
  })
  test('internal function', () => {
    const code = `
    function foobar do
    end
    function foobar do
    end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], 'foobar', 'FunctionAlreadyDeclared')
    expect(frames[0].error!.message).toBe(
      'FunctionAlreadyDeclared: name: foobar'
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
describe('UnexpectedContinueOutsideOfLoop', () => {
  test('top level', () => {
    const code = 'continue'
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'UnexpectedContinueOutsideOfLoop')
    expect(frames[0].error!.message).toBe(
      'UnexpectedContinueOutsideOfLoop: lexeme: continue'
    )
  })
  test('in statement', () => {
    const code = `
    if true do
      continue
    end`
    const { frames } = interpret(code)
    expectFrameToBeError(
      frames[1],
      'continue',
      'UnexpectedContinueOutsideOfLoop'
    )
    expect(frames[1].error!.message).toBe(
      'UnexpectedContinueOutsideOfLoop: lexeme: continue'
    )
  })
  test('next keyword', () => {
    const code = `next`
    const { error, frames } = interpret(code)
    expectFrameToBeError(frames[0], 'next', 'UnexpectedContinueOutsideOfLoop')
    expect(frames[0].error!.message).toBe(
      'UnexpectedContinueOutsideOfLoop: lexeme: next'
    )
  })
})
describe('UnexpectedBreakOutsideOfLoop', () => {
  test('top level', () => {
    const code = 'break'
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'UnexpectedBreakOutsideOfLoop')
    expect(frames[0].error!.message).toBe('UnexpectedBreakOutsideOfLoop')
  })
  test('in statement', () => {
    const code = `
    if true do
      break
    end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[1], 'break', 'UnexpectedBreakOutsideOfLoop')
    expect(frames[1].error!.message).toBe('UnexpectedBreakOutsideOfLoop')
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
  test('foreach', () => {
    const code = `set x to 5
                  for each x in "" do
                  end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[1], 'x', 'VariableAlreadyDeclared')
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
      const code = `repeat 110 times do
                      repeat 110 times do
                      end
                    end`

      const { frames } = interpret(code)
      const frame = frames[frames.length - 1]
      expectFrameToBeError(frame, 'repeat', 'MaxIterationsReached')
      expect(frame.error!.message).toBe(`MaxIterationsReached: max: 10000`)
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
    const max = 10000
    const { frames } = interpret(`
      repeat ${max + 1} times do
      end
    `)

    expectFrameToBeError(frames[0], `${max + 1}`, 'RepeatCountTooHigh')
    expect(frames[0].error!.message).toBe(
      `RepeatCountTooHigh: count: 10001, max: ${max}`
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

describe('IndexOutOfBoundsInGet', () => {
  describe('string', () => {
    test('inline on empty', () => {
      const code = 'log ""[1]'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'IndexOutOfBoundsInGet')
      expect(frames[0].error!.message).toBe(
        'IndexOutOfBoundsInGet: index: 1, length: 0, dataType: string'
      )
    })
    test('too high', () => {
      const code = 'log "foo"[4]'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'IndexOutOfBoundsInGet')
      expect(frames[0].error!.message).toBe(
        'IndexOutOfBoundsInGet: index: 4, length: 3, dataType: string'
      )
    })
  })
  describe('list', () => {
    test('inline on empty', () => {
      const code = 'log [][1]'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'IndexOutOfBoundsInGet')
      expect(frames[0].error!.message).toBe(
        'IndexOutOfBoundsInGet: index: 1, length: 0, dataType: list'
      )
    })
    test('too high', () => {
      const code = 'log [1,2,3][4]'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'IndexOutOfBoundsInGet')
      expect(frames[0].error!.message).toBe(
        'IndexOutOfBoundsInGet: index: 4, length: 3, dataType: list'
      )
    })
  })
})

describe('IndexIsZero', () => {
  describe('string', () => {
    test('get', () => {
      const code = 'log "foo"[0]'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'IndexIsZero')
      expect(frames[0].error!.message).toBe('IndexIsZero')
    })
  })
  describe('list', () => {
    test('get', () => {
      const code = 'log ["foo"][0]'
      const { frames } = interpret(code)
      expectFrameToBeError(frames[0], code, 'IndexIsZero')
      expect(frames[0].error!.message).toBe('IndexIsZero')
    })
  })
})

describe('IndexOutOfBoundsInChange', () => {
  describe('list', () => {
    test('inline on empty', () => {
      const code = `
      set list to []
      change list[1] to 5
      `
      const { frames } = interpret(code)
      expectFrameToBeError(
        frames[1],
        'change list[1] to 5',
        'IndexOutOfBoundsInChange'
      )
      expect(frames[1].error!.message).toBe(
        'IndexOutOfBoundsInChange: index: 1, length: 0, dataType: list'
      )
    })
    test('too high', () => {
      const code = `
      set list to [1,2,3]
      change list[4] to 5
      `
      const { frames } = interpret(code)
      expectFrameToBeError(
        frames[1],
        'change list[4] to 5',
        'IndexOutOfBoundsInChange'
      )
      expect(frames[1].error!.message).toBe(
        'IndexOutOfBoundsInChange: index: 4, length: 3, dataType: list'
      )
    })
  })
})

describe('InvalidChangeElementTarget', () => {
  test('string', () => {
    const code = `
      set str to "foo"
      change str[1] to "a"
      `
    const { frames } = interpret(code)
    expectFrameToBeError(frames[1], `str`, 'InvalidChangeElementTarget')
    expect(frames[1].error!.message).toBe('InvalidChangeElementTarget')
  })
})

test('ListsCannotBeCompared', () => {
  const code = `log [] == []`
  const { frames } = interpret(code)
  expectFrameToBeError(frames[0], `log [] == []`, 'ListsCannotBeCompared')
  expect(frames[0].error!.message).toBe('ListsCannotBeCompared')
})

test('VariableCannotBeNamespaced', () => {
  const code = `set foo#bar to 5`
  const { frames } = interpret(code)
  expectFrameToBeError(frames[0], code, 'VariableCannotBeNamespaced')
  expect(frames[0].error!.message).toBe(
    'VariableCannotBeNamespaced: name: foo#bar'
  )
})

describe('FunctionCannotBeNamespaced', () => {
  test('normal mode', () => {
    const code = `
      function foo#bar do
      end`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], 'foo#bar', 'FunctionCannotBeNamespaced')
    expect(frames[0].error!.message).toBe(
      'FunctionCannotBeNamespaced: name: foo#bar'
    )
  })
  // Just sanity check that this passes if we're in custom function definition mode
  test('custom function definition mode', () => {
    const code = `
      function foo#bar do
        return true
      end
      foo#bar()`
    const { frames } = interpret(code, {
      languageFeatures: { customFunctionDefinitionMode: true },
    })
    expect(frames[frames.length - 1].status).toBe('SUCCESS')
  })
})

test('ObjectsCannotBeCompared', () => {
  const context = { classes: [new Jiki.Class('Thing')] }
  const code = `
  set thing to new Thing()
  log thing == 5
  `
  const { frames } = interpret(code, context)
  expectFrameToBeError(frames[1], `log thing == 5`, 'ObjectsCannotBeCompared')
  expect(frames[1].error!.message).toBe('ObjectsCannotBeCompared')
})

test('MissingKeyInDictionary', () => {
  const code = `log {}["a"]`
  const { frames } = interpret(code)
  expectFrameToBeError(frames[0], code, 'MissingKeyInDictionary')
  expect(frames[0].error!.message).toBe('MissingKeyInDictionary: key: "a"')
})

describe('OperandMustBeString', () => {
  test('dictionary get', () => {
    const code = `log {}[1]`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'OperandMustBeString')
    expect(frames[0].error!.message).toBe('OperandMustBeString: value: 1')
  })

  test('dictionary change', () => {
    const code = `
      set foo to {}
      change foo[1] to 1
    `
    const { frames } = interpret(code)
    expectFrameToBeError(frames[1], 'change foo[1] to 1', 'OperandMustBeString')
    expect(frames[1].error!.message).toBe('OperandMustBeString: value: 1')
  })
})

describe('OperandMustBeNumber', () => {
  test('list get', () => {
    const code = `log [1]["a"]`
    const { frames } = interpret(code)
    expectFrameToBeError(frames[0], code, 'OperandMustBeNumber')
    expect(frames[0].error!.message).toBe('OperandMustBeNumber: value: "a"')
  })
  test('list change', () => {
    const code = `
      set foo to ["b"]
      change foo["a"] to 1
    `
    const { frames } = interpret(code)
    expectFrameToBeError(
      frames[1],
      'change foo["a"] to 1',
      'OperandMustBeNumber'
    )
    expect(frames[1].error!.message).toBe('OperandMustBeNumber: value: "a"')
  })
})

describe('NoneJikiObjectDetected', () => {
  test('with args', () => {
    const Person = new Jiki.Class('Person')
    // @ts-ignore
    Person.addMethod('num', '', 'public', function (_ex, _in) {
      return 5
    })

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(`log (new Person()).num()`, context)

    expect(frames[0].error!.message).toBe('NoneJikiObjectDetected')
  })
})

test('CouldNotFindGetter', () => {
  const Person = new Jiki.Class('Person')

  const context: EvaluationContext = { classes: [Person] }
  const { frames, error } = interpret(
    `set person to new Person()
      log person.foo`,
    context
  )

  expect(frames[1].error!.message).toBe('CouldNotFindGetter: name: foo')
})

test('CouldNotFindSetter', () => {
  const Person = new Jiki.Class('Person')

  const context: EvaluationContext = { classes: [Person] }
  const { frames, error } = interpret(
    `set person to new Person()
      change person.foo to 5`,
    context
  )

  expect(frames[1].error!.message).toBe('CouldNotFindSetter: name: foo')
})

test('CouldNotFindSetter', () => {
  const Person = new Jiki.Class('Person')

  const context: EvaluationContext = { classes: [Person] }
  const { frames, error } = interpret(
    `set person to new Person()
      change person.foo to 5`,
    context
  )

  expect(frames[1].error!.message).toBe('CouldNotFindSetter: name: foo')
})

describe('WrongNumberOfArgumentsInConstructor', () => {
  test('Some when none expect', () => {
    const Person = new Jiki.Class('Person')

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(
      `set person to new Person("foo")`,
      context
    )

    expect(frames[0].error!.message).toBe(
      'WrongNumberOfArgumentsInConstructor: arity: 0, numberOfArgs: 1'
    )
  })
  test('None when Some expect', () => {
    const Person = new Jiki.Class('Person')
    Person.addConstructor((ex, object, something) => {})

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(`set person to new Person()`, context)

    expect(frames[0].error!.message).toBe(
      'WrongNumberOfArgumentsInConstructor: arity: 1, numberOfArgs: 0'
    )
  })
  test('More than expected', () => {
    const Person = new Jiki.Class('Person')
    Person.addConstructor((ex, object, something) => {})

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(
      `set person to new Person(1,2,3)`,
      context
    )

    expect(frames[0].error!.message).toBe(
      'WrongNumberOfArgumentsInConstructor: arity: 1, numberOfArgs: 3'
    )
  })
  test('Inline class', () => {
    const { frames, error } = interpret(`
      class Foobar do
        constructor with something do
        end
      end
      log new Foobar("too", "many")`)

    expect(frames.at(-1)?.error!.message).toBe(
      'WrongNumberOfArgumentsInConstructor: arity: 1, numberOfArgs: 2'
    )
  })
})

test('ClassNotFound', () => {
  const { frames, error } = interpret(`set person to new Person(1,2,3)`)
  expect(frames[0].error!.message).toBe('ClassNotFound')
})

test('CouldNotFindMethod', () => {
  const Person = new Jiki.Class('Person')

  const context: EvaluationContext = { classes: [Person] }
  const { frames, error } = interpret(
    `set person to new Person()
    person.foobar()`,
    context
  )

  expect(frames[1].error!.message).toBe('CouldNotFindMethod')
})

describe('AccessorUsedOnNonInstance', () => {
  test('List', () => {
    const { frames } = interpret(`log [].foo`)
    expect(frames[0].error!.message).toBe('AccessorUsedOnNonInstance')
  })
  test('Dict', () => {
    const { frames } = interpret(`log {}.foo`)
    expect(frames[0].error!.message).toBe('AccessorUsedOnNonInstance')
  })
  test('String', () => {
    const { frames } = interpret(`log "".foo`)
    expect(frames[0].error!.message).toBe('AccessorUsedOnNonInstance')
  })
})

describe('UnexpectedForeachSecondElementName', () => {
  test('List', () => {
    const { frames } = interpret(`
      for each foo, bar in [] do
      end`)
    expect(frames[0].error!.message).toBe(
      'UnexpectedForeachSecondElementName: type: list'
    )
  })
  test('String', () => {
    const { frames } = interpret(`
      for each foo, bar in "" do
      end`)
    expect(frames[0].error!.message).toBe(
      'UnexpectedForeachSecondElementName: type: string'
    )
  })
})

test('MissingForeachSecondElementName', () => {
  const { frames } = interpret(`
    for each foo in {} do
    end`)
  expect(frames[0].error!.message).toBe('MissingForeachSecondElementName')
})

// TOOD: Strings are immutable

// UnexpectedObjectArgumentForCustomFunction

test('UnexpectedObjectArgumentForCustomFunction', () => {
  const customFunction = {
    name: 'my#foobar',
    arity: 1,
    description: '',
    code: '',
  }
  const Person = new Jiki.Class('Person')
  const context: EvaluationContext = {
    customFunctions: [customFunction],
    classes: [Person],
  }

  const { frames, error } = interpret(
    `
    set person to new Person()
    my#foobar(person)
  `,
    context
  )

  expect(frames[1].error!.message).toBe(
    'UnexpectedObjectArgumentForCustomFunction'
  )
})

describe('ConstructorDidNotSetProperty', () => {
  test('no constructor', () => {
    const { frames, error } = interpret(`
      class Foobar do
        public property foo
      end
      log new Foobar()
    `)

    expect(frames[0].error!.message).toBe(
      'ConstructorDidNotSetProperty: property: foo'
    )
  })
  test('lazy constructor', () => {
    const { frames, error } = interpret(`
      class Foobar do
        public property foo
        constructor do
        end
      end
      log new Foobar()
    `)

    expect(frames[0].error!.message).toBe(
      'ConstructorDidNotSetProperty: property: foo'
    )
  })
  test('only one property', () => {
    const { frames, error } = interpret(`
      class Foobar do
        public property foo
        public property bar
        public property baz

        constructor do
          set this.foo to 5
        end
      end
      log new Foobar()
    `)

    expect(frames.at(-1)?.error!.message).toBe(
      'ConstructorDidNotSetProperty: property: bar'
    )
  })
})

test('ClassAlreadyDefined', () => {
  const { frames, error } = interpret(`
    class Foobar do
    end
    class Foobar do
    end
  `)

  expect(frames.at(-1)?.error!.message).toBe(
    'ClassAlreadyDefined: name: Foobar'
  )
})

test('UnexpectedChangeOfMethod', () => {
  const { frames, error } = interpret(`
    class Foobar do
      public method foo do
      end

      constructor do
        set this.foo to 5
      end
    end
    log new Foobar()
  `)

  expect(frames.at(-1)?.error!.message).toBe(
    'UnexpectedChangeOfMethod: name: foo'
  )
})
test('PropertySetterUsedOnNonProperty', () => {
  const { frames, error } = interpret(`
    class Foobar do
      constructor do
        set this.foo to 5
      end
    end
    log new Foobar()
  `)

  expect(frames.at(-1)?.error!.message).toBe(
    'PropertySetterUsedOnNonProperty: name: foo'
  )
})
test('MethodUsedAsGetter', () => {
  const { frames, error } = interpret(`
    class Foobar do
      public method foo do
      end
    end
    log (new Foobar()).foo
  `)

  expect(frames.at(-1)?.error!.message).toBe('MethodUsedAsGetter: name: foo')
})

describe('ClassCannotBeUsedAsVariable', () => {
  test('as object', () => {
    const { frames, error } = interpret(`
      class Foobar do
      end
      Foobar.say()
    `)

    expect(frames.at(-1)?.error!.message).toBe(
      'ClassCannotBeUsedAsVariable: name: Foobar'
    )
  })
  test('as arg', () => {
    const { frames, error } = interpret(`
      function say do
      end
      class Foobar do
      end
      say(Foobar)
    `)

    expect(frames.at(-1)?.error!.message).toBe(
      'ClassCannotBeUsedAsVariable: name: Foobar'
    )
  })
})

describe('ThisUsedOutsideOfMethod', () => {
  test('top level', () => {
    const { frames, error } = interpret(`
      log this
    `)

    expect(frames.at(-1)?.error!.message).toBe('ThisUsedOutsideOfMethod')
  })
  test('function', () => {
    const { frames, error } = interpret(`
      function foo do
        log this.bar
      end
      foo()
    `)

    expect(frames.at(-1)?.error!.message).toBe('ThisUsedOutsideOfMethod')
  })
  test('constructor -> function', () => {
    const { frames, error } = interpret(`
      function foo do
        log this.bar
      end
      class Foobar do
        public property bar
        constructor do
          foo()
        end
      end
      log new Foobar()
    `)

    expect(frames.at(-1)?.error!.message).toBe('ThisUsedOutsideOfMethod')
  })
  test('method -> function', () => {
    const { frames, error } = interpret(`
      function foo do
        log this.bar
      end
      class Foobar do
        public property bar
        constructor do
          set this.bar to 5
        end
        public method baz do
          foo()
        end
      end
      set x to new Foobar()
      log x.baz()
    `)

    expect(frames.at(-1)?.error!.message).toBe('ThisUsedOutsideOfMethod')
  })
})
// AttemptedToAccessPrivateMethod
test('AttemptedToAccessPrivateMethod', () => {
  const { frames, error } = interpret(`
    class Foobar do
      private method foo do
      end
    end
    log (new Foobar()).foo()
  `)

  expect(frames.at(-1)?.error!.message).toBe('AttemptedToAccessPrivateMethod')
})
test('AttemptedToAccessPrivateGetter', () => {
  const { frames, error } = interpret(`
    class Foobar do
      private property foo
        constructor do
          set this.foo to 5
        end
    end
    log (new Foobar()).foo
  `)

  expect(frames.at(-1)?.error!.message).toBe('AttemptedToAccessPrivateGetter')
})
test('AttemptedToAccessPrivateSetter', () => {
  const { frames, error } = interpret(`
    class Foobar do
      private property foo
        constructor do
          set this.foo to 5
        end
    end
    set x to new Foobar()
    change x.foo to 5
  `)

  expect(frames.at(-1)?.error!.message).toBe('AttemptedToAccessPrivateSetter')
})
test('AttemptedToAccessPrivateSetter', () => {
  const { frames, error } = interpret(`
    class Foobar do
      private property foo
      constructor do
        set this.foo to 5
      end
    end
    set x to new Foobar()
    change x.foo to 5
  `)

  expect(frames.at(-1)?.error!.message).toBe('AttemptedToAccessPrivateSetter')
})
test('PropertyAlreadySet', () => {
  const { frames, error } = interpret(`
    class Foobar do
      private property foo
      constructor do
        set this.foo to 3
      end

      public method bar do
        set this.foo to 5
      end
    end
    set x to new Foobar()
    x.bar()
  `)

  expect(frames.at(-1)?.error!.message).toBe('PropertyAlreadySet: name: foo')
})
