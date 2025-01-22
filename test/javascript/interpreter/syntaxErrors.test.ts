import { parse } from '@/interpreter/parser'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('syntax errors', () => {
  describe('numbers', () => {
    test('two periods', () => {
      expect(() => parse('1.3.4')).toThrow(
        'NumberWithMultipleDecimalPoints: suggestion: 1.34'
      )
    })

    test('unfinished decimal number', () => {
      expect(() => parse('123.')).toThrow(
        'NumberEndsWithDecimalPoint: suggestion: 123'
      )
    })

    test('invalid character in number', () => {
      expect(() => parse('set x to 123abc')).toThrow(
        'NumberContainsAlpha: suggestion: 123'
      )
    })

    test('leading zeros', () => {
      expect(() => parse('set x to 00123')).toThrow(
        'NumberStartsWithZero: suggestion: 123'
      )
    })
  })

  describe('strings', () => {
    test('unstarted', () => {
      expect(() => parse('abc"')).toThrow(
        'MissingDoubleQuoteToStartString: string: abc'
      )
    })

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

  describe('assignment', () => {
    test('using = by accident', () => {
      expect(() => parse('set value = "value"')).toThrow(
        'UnexpectedEqualsForAssignment'
      )
    })

    test('number as variable name', () => {
      expect(() => parse('set 123 to "value"')).toThrow(
        'InvalidNumericVariableName: name: 123'
      )
    })

    test('missing to', () => {
      expect(() => parse('set name "Jeremy"')).toThrow(
        'MissingToAfterVariableNameToInitializeValue: name'
      )
    })
    test('two identifiers', () => {
      expect(() => parse('set na me to "Jeremy"')).toThrow(
        'UnexpectedSpaceInIdentifier: first_half: na, second_half: me'
      )
    })
  })

  describe('function definitions', () => {
    test('missing function name', () => {
      expect(() =>
        parse(`
          function with x, y do
            set result to x + y
          end
        `)
      ).toThrow('MissingFunctionName')
    })

    test('missing with', () => {
      expect(() =>
        parse(`
        function foobar a do
        end
      `)
      ).toThrow('MissingWithBeforeParameters')
    })

    test('missing do', () => {
      expect(() =>
        parse(`
        function foobar with a
        end
      `)
      ).toThrow('MissingDoToStartBlock: type: function')
    })

    test('missing end', () => {
      expect(() =>
        parse(`
        function foobar with a do
      `)
      ).toThrow('MissingEndAfterBlock: type: function')
    })

    test('missing parameters', () => {
      expect(() =>
        parse(`
          function move with do
            set result to 10
          end
        `)
      ).toThrow('MissingParameterName')
    })

    test('unexpected token after function name', () => {
      expect(() =>
        parse(`
          function move unexpected (x, y) do
            set result to x + y
          end
        `)
      ).toThrow('MissingWithBeforeParameters')
    })

    test("extra tokens after 'end' keyword", () => {
      expect(() =>
        parse(`
          function move with x, y do
            set result to x + y
          end end
        `)
      ).toThrow('MissingEndOfLine: previous: end')
    })

    test('invalid parameter name', () => {
      expect(() =>
        parse(`
          function move with 1x, y do
            set result to x + y
          end
        `)
      ).toThrow('NumberContainsAlpha: suggestion: 1')
    })

    test('missing comma between parameters', () => {
      expect(() =>
        parse(`
          function move with x y do
            set result to x + y
          end
        `)
      ).toThrow('MissingCommaBetweenParameters: parameter: x')
    })

    test('duplicate parameter names', () => {
      expect(() =>
        parse(`
          function move with x, x do
            set result to x + x
          end
        `)
      ).toThrow('DuplicateParameterName: parameter: x')
    })

    test('empty parameter list with invalid syntax', () => {
      expect(() =>
        parse(`
          function move with do
            set result to 10
          end
        `)
      ).toThrow('MissingParameterName')
    })

    test('unexpected token inside parameter list', () => {
      expect(() =>
        parse(`
          function move with x, unexpected y do
            set result to x + y
          end
        `)
      ).toThrow('MissingCommaBetweenParameters: parameter: unexpected')
    })
  })

  describe('function definition', () => {
    test('missing opening parenthesis', () => {
      expect(() =>
        parse(`
          function move do
            return 1
          end

          move)
        `)
      ).toThrow('MissingLeftParenthesisAfterFunctionCall: function: move')
    })

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

  describe('statement', () => {
    test('multiple expressions on single line', () => {
      expect(() => parse('1 1')).toThrow('MissingEndOfLine')
    })
  })

  describe('invalid characters', () => {
    test('using = for assignment', () => {
      expect(() => parse('set x = "value"')).toThrow(
        'UnexpectedEqualsForAssignment'
      )
    })

    test('using = for equality', () => {
      expect(() => parse('if a = "value"')).toThrow(
        'UnexpectedEqualsForEquality'
      )
    })
    test('using = for equality in assignment', () => {
      expect(() => parse('set a to x = "value"')).toThrow(
        'UnexpectedEqualsForEquality'
      )
    })
  })

  describe('missing do', () => {
    test('repeat', () => {
      expect(() =>
        parse(`
        repeat 5 times
        end
      `)
      ).toThrow('MissingDoToStartBlock: type: repeat')
    })

    test('while', () => {
      expect(() =>
        parse(`
        while x equals 1
        end
      `)
      ).toThrow('MissingDoToStartBlock: type: while')
    })
  })

  describe('missing end', () => {
    test('repeat', () => {
      expect(() =>
        parse(`
        repeat 5 times do
      `)
      ).toThrow('MissingEndAfterBlock: type: repeat')
    })

    test('while', () => {
      expect(() =>
        parse(`
        while x equals 1 do
      `)
      ).toThrow('MissingEndAfterBlock: type: while')
    })
  })

  describe('if/else statements', () => {
    test('missing do on if', () => {
      expect(() =>
        parse(`
        if 5 > 4
        end
      `)
      ).toThrow('MissingDoToStartBlock: type: if')
    })

    test('missing do on else', () => {
      expect(() =>
        parse(`
        if 5 > 4 do
        else
        end
      `)
      ).toThrow('MissingDoToStartBlock: type: else')
    })

    test('missing end on if', () => {
      expect(() =>
        parse(`
        if 5 > 4 do
      `)
      ).toThrow('MissingEndAfterBlock: type: if')
    })

    test('missing end on else', () => {
      expect(() =>
        parse(`
        if 5 > 4 do
        else do
      `)
      ).toThrow('MissingEndAfterBlock: type: else')
    })

    test('missing condition in if statement', () => {
      expect(() =>
        parse(`
          if do
            set x to 10
          end
        `)
      ).toThrow('MissingConditionAfterIf')
    })

    test('else without matching if', () => {
      expect(() =>
        parse(`
          else
            set x to 10
          end
        `)
      ).toThrow('UnexpectedElseWithoutIf')
    })

    test('else if without matching if', () => {
      expect(() =>
        parse(`
          else if x is 10 do
            set x to 20
          end
        `)
      ).toThrow('UnexpectedElseWithoutIf')
    })

    test('missing condition in else if', () => {
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

    test('misspelt comparison operator', () => {
      expect(() =>
        parse(`
          if x equal 10 do
            set x to 20
          end
        `)
      ).toThrow(
        'UnexpectedVariableExpressionAfterIfWithPotentialTypo: actual: equal, potential: equals'
      )
    })

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

    test('nested if without end', () => {
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

    test('unexpected token after if condition', () => {
      expect(() =>
        parse(`
          if x is 10 unexpected
            set x to 20
          end
        `)
      ).toThrow('MissingDoToStartBlock: type: if')
    })

    test('literal conditions', () => {
      expect(() =>
        parse(`
          if true do
            set x to 20
          end
        `)
      ).toThrow('UnexpectedLiteralExpressionAfterIf')
    })

    test('variable conditions', () => {
      expect(() =>
        parse(`
          if something do
            set x to 20
          end
        `)
      ).toThrow('UnexpectedVariableExpressionAfterIf')
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

  describe('call', () => {
    test('missing opening parenthesis', () => {
      expect(() =>
        parse(`
          function move do
            return 1
          end

          move)
        `)
      ).toThrow('MissingLeftParenthesisAfterFunctionCall: function: move')
    })

    test('missing closing parenthesis', () => {
      expect(() => parse('move(1')).toThrow(
        'MissingRightParenthesisAfterFunctionCall: function: move'
      )
    })
  })
})
