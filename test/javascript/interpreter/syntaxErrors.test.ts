import { parse } from '@/interpreter/parser'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('InvalidFunctionName', () => {
  test('number as a function name', () => {
    expect(() => parse('1()')).toThrow('InvalidFunctionName')
  })
  test('boolean as a function name', () => {
    expect(() => parse('true()')).toThrow('InvalidFunctionName')
  })
})

//
// Numbers
//
test('NumberWithMultipleDecimalPoints', () => {
  expect(() => parse('1.3.4')).toThrow(
    'NumberWithMultipleDecimalPoints: suggestion: 1.34'
  )
})

test('NumberEndsWithDecimalPoint', () => {
  expect(() => parse('123.')).toThrow(
    'NumberEndsWithDecimalPoint: suggestion: 123'
  )
})

test('NumberContainsAlpha', () => {
  expect(() => parse('set x to 123abc')).toThrow(
    'NumberContainsAlpha: suggestion: 123'
  )
})

test('NumberStartsWithZero', () => {
  expect(() => parse('set x to 00123')).toThrow(
    'NumberStartsWithZero: suggestion: 123'
  )
})

//
// Strings
//
test('MissingDoubleQuoteToStartString', () => {
  expect(() => parse('abc"')).toThrow(
    'MissingDoubleQuoteToStartString: string: abc'
  )
})

describe('MissingDoubleQuoteToTerminateString', () => {
  test('unterminated - end of file', () => {
    expect(() => parse('"abc')).toThrow(
      'MissingDoubleQuoteToTerminateString: string: abc'
    )
  })

  test('unterminated - end of line', () => {
    expect(() => parse('"abc\nsomething_else"')).toThrow(
      'MissingDoubleQuoteToTerminateString: string: abc'
    )
  })

  test('unterminated - newline in string', () => {
    expect(() => parse('"abc\n"')).toThrow(
      'MissingDoubleQuoteToTerminateString: string: abc'
    )
  })
})

//
// Assignment
//
test('UnexpectedEqualsForAssignment', () => {
  expect(() => parse('set value = "value"')).toThrow(
    'UnexpectedEqualsForAssignment'
  )
})

test('InvalidNumericVariableName', () => {
  expect(() => parse('set 123 to "value"')).toThrow(
    'InvalidNumericVariableName: name: 123'
  )
})

test('MissingToAfterVariableNameToInitializeValue', () => {
  expect(() => parse('set name "Jeremy"')).toThrow(
    'MissingToAfterVariableNameToInitializeValue: name'
  )
})
test('UnexpectedSpaceInIdentifier', () => {
  expect(() => parse('set na me to "Jeremy"')).toThrow(
    'UnexpectedSpaceInIdentifier: first_half: na, second_half: me'
  )
})

// Function definitions
test('MissingFunctionName', () => {
  expect(() =>
    parse(`
      function with x, y do
        set result to x + y
      end
    `)
  ).toThrow('MissingFunctionName')
})

test('MissingWithBeforeParameters', () => {
  expect(() =>
    parse(`
    function foobar a do
    end
  `)
  ).toThrow('MissingWithBeforeParameters')
})

test('MissingDoToStartBlock', () => {
  expect(() =>
    parse(`
    function foobar with a
    end
  `)
  ).toThrow('MissingDoToStartBlock: type: function')
})

test('MissingEndAfterBlock', () => {
  expect(() =>
    parse(`
    function foobar with a do
  `)
  ).toThrow('MissingEndAfterBlock: type: function')
})

test('MissingParameterName', () => {
  expect(() =>
    parse(`
      function move with do
        set result to 10
      end
    `)
  ).toThrow('MissingParameterName')
})

test('MissingWithBeforeParameters', () => {
  expect(() =>
    parse(`
      function move unexpected (x, y) do
        set result to x + y
      end
    `)
  ).toThrow('MissingWithBeforeParameters')
})

describe('MissingEndOfLine', () => {
  test('Two expressions', () => {
    expect(() => parse('log 1 1')).toThrow('MissingEndOfLine')
  })

  test('Two ends', () => {
    expect(() =>
      parse(`
        function move with x, y do
          set result to x + y
        end end
      `)
    ).toThrow('MissingEndOfLine: previous: end')
  })
})

test('NumberContainsAlpha', () => {
  expect(() =>
    parse(`
      function move with 1x, y do
        set result to x + y
      end
    `)
  ).toThrow('NumberContainsAlpha: suggestion: 1')
})

test('MissingCommaBetweenParameters', () => {
  expect(() =>
    parse(`
      function move with x y do
        set result to x + y
      end
    `)
  ).toThrow('MissingCommaBetweenParameters: parameter: x')
})

test('DuplicateParameterName', () => {
  expect(() =>
    parse(`
      function move with x, x do
        set result to x + x
      end
    `)
  ).toThrow('DuplicateParameterName: parameter: x')
})

test('MissingParameterName', () => {
  expect(() =>
    parse(`
      function move with do
        set result to 10
      end
    `)
  ).toThrow('MissingParameterName')
})

test('MissingCommaBetweenParameters', () => {
  expect(() =>
    parse(`
      function move with x, unexpected y do
        set result to x + y
      end
    `)
  ).toThrow('MissingCommaBetweenParameters: parameter: unexpected')
})

describe('MissingRightParenthesisAfterFunctionCall', () => {
  test('missing closing parenthesis - no args', () => {
    expect(() => parse('move(')).toThrow(
      'MissingRightParenthesisAfterFunctionCall: function: move'
    )
  })

  test('missing closing parenthesis - 1 arg', () => {
    expect(() => parse('move(1')).toThrow(
      'MissingRightParenthesisAfterFunctionCall: function: move'
    )
  })

  test('missing closing parenthesis - 2 args', () => {
    expect(() => parse('move(1, 2')).toThrow(
      'MissingRightParenthesisAfterFunctionCall: function: move'
    )
  })
})

test('UnexpectedEqualsForAssignment', () => {
  expect(() => parse('set x = "value"')).toThrow(
    'UnexpectedEqualsForAssignment'
  )
})
describe('UnexpectedEqualsForEquality', () => {
  test('in condition', () => {
    expect(() => parse('if a = "value"')).toThrow('UnexpectedEqualsForEquality')
  })
  test('in assignment', () => {
    expect(() => parse('set a to x = "value"')).toThrow(
      'UnexpectedEqualsForEquality'
    )
  })
})

describe('MissingDoToStartBlock', () => {
  test('repeat', () => {
    expect(() =>
      parse(`
      repeat 5 times
      end
    `)
    ).toThrow('MissingDoToStartBlock: type: repeat')
  })

  test.skip('while', () => {
    expect(() =>
      parse(`
      while x equals 1
      end
    `)
    ).toThrow('MissingDoToStartBlock: type: while')
  })
  test('if', () => {
    expect(() =>
      parse(`
      if x equals 1
      end
    `)
    ).toThrow('MissingDoToStartBlock: type: if')
  })

  test('if with unexpected token', () => {
    expect(() =>
      parse(`
      if x is 10 unexpected
        set x to 20
      end
    `)
    ).toThrow('MissingDoToStartBlock: type: if')
  })

  test('else', () => {
    expect(() =>
      parse(`
      if 5 > 4 do
      else
      end
    `)
    ).toThrow('MissingDoToStartBlock: type: else')
  })
})

describe('MissingEndAfterBlock', () => {
  test('repeat', () => {
    expect(() =>
      parse(`
      repeat 5 times do
    `)
    ).toThrow('MissingEndAfterBlock: type: repeat')
  })

  test.skip('while', () => {
    expect(() =>
      parse(`
      while x equals 1 do
    `)
    ).toThrow('MissingEndAfterBlock: type: while')
  })
  test('if', () => {
    expect(() =>
      parse(`
      if x equals 1 do
    `)
    ).toThrow('MissingEndAfterBlock: type: if')
  })

  test('else', () => {
    expect(() =>
      parse(`
      if 5 > 4 do
      else do
    `)
    ).toThrow('MissingEndAfterBlock: type: else')
  })

  test('nested ifs', () => {
    expect(() =>
      parse(`
        if x is 10 do
          if y is 20 do
            set x to 30
          set y to 40
        end
      `)
    ).toThrow('MissingEndAfterBlock: type: if')
  })
})

describe('UnexpectedElseWithoutIf', () => {
  test('else', () => {
    expect(() =>
      parse(`
        else
          set x to 10
        end
      `)
    ).toThrow('UnexpectedElseWithoutIf')
  })

  test('else if', () => {
    expect(() =>
      parse(`
        else if x is 10 do
          set x to 20
        end
      `)
    ).toThrow('UnexpectedElseWithoutIf')
  })

  // TODO: Could we do better here?
  test('multiple else statements', () => {
    expect(() =>
      parse(`
        if x is 10 do
          set x to 20
        else do
          set x to 30
        else do
          set x to 40
        end
      `)
    ).toThrow('UnexpectedElseWithoutIf')
  })
})

describe('MissingConditionAfterIf', () => {
  test('if', () => {
    expect(() =>
      parse(`
        if do
          set x to 10
        end
      `)
    ).toThrow('MissingConditionAfterIf')
  })
  test('else if', () => {
    expect(() =>
      parse(`
        if x is 10 do
          set x to 20
        else if do
          set x to 30
        end
      `)
    ).toThrow('MissingConditionAfterIf')
  })
})

describe('UnexpectedVariableExpressionAfterIfWithPotentialTypo', () => {
  test('misspelt comparison operator with brackets', () => {
    expect(() =>
      parse(`
        if(x equal 10) do
          set x to 20
        end
      `)
    ).toThrow(
      'MissingRightParenthesisAfterExpressionWithPotentialTypo: actual: equal, potential: equals'
    )
  })
})

test('InvalidNestedFunction', () => {
  expect(() =>
    parse(`
      function outer do
        function inner do
          return 1
        end
      end
    `)
  ).toThrow('InvalidNestedFunction')
})

describe('chained things', () => {
  test('triple equals', () => {
    expect(() => parse('1 == 2 == 3')).toThrow('UnexpectedChainedEquality')
  })
  test.skip('triple not equals', () => {
    expect(() => parse('1 != 2 != 3')).toThrow('UnexpectedChainedEquality')
  })
})

describe('MiscapitalizedKeyword', () => {
  test('initial letter is wrong', () => {
    expect(() => parse('If x to 10')).toThrow(
      'MiscapitalizedKeyword: actual: If, expected: if'
    )
  })
  test('later letter is wrong', () => {
    expect(() => parse('seT x to 10')).toThrow(
      'MiscapitalizedKeyword: actual: seT, expected: set'
    )
  })
  test('all wrong', () => {
    expect(() => parse('FUNCTION something do')).toThrow(
      'MiscapitalizedKeyword: actual: FUNCTION, expected: function'
    )
  })
})

describe('PointlessStatement', () => {
  test('with a literal', () => {
    expect(() => parse('10')).toThrow('PointlessStatement')
  })
  test('with a literal in a group', () => {
    expect(() => parse('(10)')).toThrow('PointlessStatement')
  })
})

test('PotentialMissingParenthesesForFunctionCall', () => {
  expect(() => parse('foo')).toThrow(
    'PotentialMissingParenthesesForFunctionCall'
  )
})

test('MissingEachAfterFor', () => {
  expect(() =>
    parse(`
      for elem in [] do
        set x to elem
      end
    `)
  ).toThrow('MissingEachAfterFor')
})

describe('MissingRightBracketAfterListElements', () => {
  test('one line', () => {
    expect(() =>
      parse(`
        set foo to [1, 2,
      `)
    ).toThrow('MissingRightBracketAfterListElements')
  })
  test('multiple lines', () => {
    expect(() =>
      parse(`
        set foo to [1,
                    2,
      `)
    ).toThrow('MissingRightBracketAfterListElements')
  })
  test('new statement with comma', () => {
    expect(() =>
      parse(`
        set foo to [1, 2,
        set x to 1
      `)
    ).toThrow('MissingRightBracketAfterListElements')
  })
  test('new statement without comma', () => {
    expect(() =>
      parse(`
        set foo to [1, 2
        set x to 1
      `)
    ).toThrow('MissingRightBracketAfterListElements')
  })
  test('new statement without elements', () => {
    expect(() =>
      parse(`
        set foo to [
        set x to 1
      `)
    ).toThrow('MissingRightBracketAfterListElements')
  })
  test('before a do', () => {
    expect(() =>
      parse(`
        for each x in [1 do
        set x to 1
      `)
    ).toThrow('MissingRightBracketAfterListElements')
  })
})

describe('MissingCommaInList', () => {
  test('one line', () => {
    expect(() =>
      parse(`
        set foo to [1 2
      `)
    ).toThrow('MissingCommaInList')
  })
  test('multiple lines', () => {
    expect(() =>
      parse(`
        set foo to [1 
                    2
      `)
    ).toThrow('MissingCommaInList')
  })
})

describe('MissingRightBraceAfterDictionaryElements', () => {
  test('one line', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2",
      `)
    ).toThrow('MissingRightBraceAfterDictionaryElements')
  })

  test('multiple lines', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2",
                    "3": 4,
      `)
    ).toThrow('MissingRightBraceAfterDictionaryElements')
  })
  test('new statement with comma', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2",
        set x to 1
      `)
    ).toThrow('MissingRightBraceAfterDictionaryElements')
  })
  test('new statement without comma', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2"
        set x to 1
      `)
    ).toThrow('MissingRightBraceAfterDictionaryElements')
  })

  test('new statement without elements', () => {
    expect(() =>
      parse(`
        set foo to {
        set x to 1
      `)
    ).toThrow('MissingRightBraceAfterDictionaryElements')
  })
  test('before a do', () => {
    expect(() =>
      parse(`
        for each x in {"1": "2" do
        end
      `)
    ).toThrow('MissingRightBraceAfterDictionaryElements')
  })
})

describe('MissingCommaInDictionary', () => {
  test('one line', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2" "3"
      `)
    ).toThrow('MissingCommaInDictionary')
  })
  test('multiple lines', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2"
                    "3"
      `)
    ).toThrow('MissingCommaInDictionary')
  })
})

describe('UnexpectedTrailingComma', () => {
  test('dictionary with elems', () => {
    expect(() =>
      parse(`
        set foo to {"1": "2",}
      `)
    ).toThrow('UnexpectedTrailingComma')
  })
  test('naked dictionary', () => {
    expect(() =>
      parse(`
        set foo to {,}
      `)
    ).toThrow('UnexpectedTrailingComma')
  })
  test('list with elems', () => {
    expect(() =>
      parse(`
        set foo to ["1", "2",]
      `)
    ).toThrow('UnexpectedTrailingComma')
  })
  test('naked list', () => {
    expect(() =>
      parse(`
        set foo to [,]
      `)
    ).toThrow('UnexpectedTrailingComma')
  })
})

describe('UnexpectedKeyword', () => {
  test('function definition', () => {
    expect(() =>
      parse(`function can_fit_in with queue, next, time do`)
    ).toThrow('UnexpectedKeyword: lexeme: next')
  })
})
