import { scan } from '@/css-interpreter/scanner'
import { type TokenType } from '@/css-interpreter/token'

describe('single-character', () => {
  test.each([
    ['{', 'LEFT_BRACE'],
    ['}', 'RIGHT_BRACE'],
    ['(', 'LEFT_PAREN'],
    [')', 'RIGHT_PAREN'],
    [':', 'COLON'],
    [',', 'COMMA'],
    [';', 'SEMICOLON'],
  ])("'%s' token", (source: string, expectedType: string) => {
    const tokens = scan(source)
    expect(tokens[0].type).toBe(expectedType as TokenType)
    expect(tokens[0].lexeme).toBe(source)
    expect(tokens[0].literal).toBeNull
  })
})

describe('string', () => {
  test('empty', () => {
    const tokens = scan('""')
    expect(tokens[0].type).toBe('STRING')
    expect(tokens[0].lexeme).toBe('""')
    expect(tokens[0].literal).toBe('')
  })

  test('single character', () => {
    const tokens = scan('"a"')
    expect(tokens[0].type).toBe('STRING')
    expect(tokens[0].lexeme).toBe('"a"')
    expect(tokens[0].literal).toBe('a')
  })

  test('multiple characters', () => {
    const tokens = scan('"Hello"')
    expect(tokens[0].type).toBe('STRING')
    expect(tokens[0].lexeme).toBe('"Hello"')
    expect(tokens[0].literal).toBe('Hello')
  })

  test('containing whitespace', () => {
    const tokens = scan('" Good\tday! "')
    expect(tokens[0].type).toBe('STRING')
    expect(tokens[0].lexeme).toBe('" Good\tday! "')
    expect(tokens[0].literal).toBe(' Good\tday! ')
  })

  test('containing number', () => {
    const tokens = scan('"Testing 1,2,3"')
    expect(tokens[0].type).toBe('STRING')
    expect(tokens[0].lexeme).toBe('"Testing 1,2,3"')
    expect(tokens[0].literal).toBe('Testing 1,2,3')
  })
})

describe('identifier', () => {
  test('start with lower letter', () => {
    const tokens = scan('name')
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[0].lexeme).toBe('name')
    expect(tokens[0].literal).toBeNull
  })

  test('start with upper letter', () => {
    const tokens = scan('Name')
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[0].lexeme).toBe('Name')
    expect(tokens[0].literal).toBeNull
  })

  test('start with underscore', () => {
    const tokens = scan('_name')
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[0].lexeme).toBe('_name')
    expect(tokens[0].literal).toBeNull
  })
  test('start with dot', () => {
    const tokens = scan('.name')
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[0].lexeme).toBe('.name')
    expect(tokens[0].literal).toBeNull
  })
  test('start with hash', () => {
    const tokens = scan('#name')
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[0].lexeme).toBe('#name')
    expect(tokens[0].literal).toBeNull
  })
})

describe('number', () => {
  test('integer', () => {
    const tokens = scan('143')
    expect(tokens[0].type).toBe('NUMBER')
    expect(tokens[0].lexeme).toBe('143')
    expect(tokens[0].literal).toBe(143)
  })

  test('floating-point', () => {
    const tokens = scan('76.9')
    expect(tokens[0].type).toBe('NUMBER')
    expect(tokens[0].lexeme).toBe('76.9')
    expect(tokens[0].literal).toBe(76.9)
  })
})

test('multiple lines', () => {
  const tokens = scan('move()\nturn("left")\nmove()')
  expect(tokens).toBeArrayOfSize(11)
  expect(tokens[0].type).toBe('IDENTIFIER')
  expect(tokens[1].type).toBe('LEFT_PAREN')
  expect(tokens[2].type).toBe('RIGHT_PAREN')
  expect(tokens[3].type).toBe('IDENTIFIER')
  expect(tokens[4].type).toBe('LEFT_PAREN')
  expect(tokens[5].type).toBe('STRING')
  expect(tokens[6].type).toBe('RIGHT_PAREN')
  expect(tokens[7].type).toBe('IDENTIFIER')
  expect(tokens[8].type).toBe('LEFT_PAREN')
  expect(tokens[9].type).toBe('RIGHT_PAREN')
  expect(tokens[10].type).toBe('EOF')
})

test('location', () => {
  const tokens = scan('move()\nturn("left")')
  expect(tokens).toBeArrayOfSize(8)

  expect(tokens[0].location.line).toBe(1)
  expect(tokens[0].location.relative.begin).toBe(1)
  expect(tokens[0].location.relative.end).toBe(5)
  expect(tokens[0].location.absolute.begin).toBe(1)
  expect(tokens[0].location.absolute.end).toBe(5)

  expect(tokens[1].location.line).toBe(1)
  expect(tokens[1].location.relative.begin).toBe(5)
  expect(tokens[1].location.relative.end).toBe(6)
  expect(tokens[1].location.absolute.begin).toBe(5)
  expect(tokens[1].location.absolute.end).toBe(6)

  expect(tokens[2].location.line).toBe(1)
  expect(tokens[2].location.relative.begin).toBe(6)
  expect(tokens[2].location.relative.end).toBe(7)
  expect(tokens[2].location.absolute.begin).toBe(6)
  expect(tokens[2].location.absolute.end).toBe(7)

  expect(tokens[3].location.line).toBe(2)
  expect(tokens[3].location.relative.begin).toBe(1)
  expect(tokens[3].location.relative.end).toBe(5)
  expect(tokens[3].location.absolute.begin).toBe(8)
  expect(tokens[3].location.absolute.end).toBe(12)

  expect(tokens[4].location.line).toBe(2)
  expect(tokens[4].location.relative.begin).toBe(5)
  expect(tokens[4].location.relative.end).toBe(6)
  expect(tokens[4].location.absolute.begin).toBe(12)
  expect(tokens[4].location.absolute.end).toBe(13)

  expect(tokens[5].location.line).toBe(2)
  expect(tokens[5].location.relative.begin).toBe(6)
  expect(tokens[5].location.relative.end).toBe(12)
  expect(tokens[5].location.absolute.begin).toBe(13)
  expect(tokens[5].location.absolute.end).toBe(19)

  expect(tokens[6].location.line).toBe(2)
  expect(tokens[6].location.relative.begin).toBe(12)
  expect(tokens[6].location.relative.end).toBe(13)
  expect(tokens[6].location.absolute.begin).toBe(19)
  expect(tokens[6].location.absolute.end).toBe(20)
})

describe('error', () => {
  describe.skip('token', () => {
    test('invalid', () => {
      expect(() => scan('123#')).toThrow("Unknown character: '#'.")
    })

    test('Exclude listed', () => {
      expect(() => scan('set x to 1', { excludeList: ['SET'] })).toThrow(
        "Jiki doesn't know how to use `set` in this exercise."
      )
    })

    test('Include listed', () => {
      expect(() =>
        scan('set x to 1', {
          includeList: ['IDENTIFIER', 'NUMBER'],
        })
      ).toThrow("Jiki doesn't know how to use `set` in this exercise.")
    })
  })
})

describe('white space', () => {
  describe('ignore', () => {
    test('spaces', () => {
      const tokens = scan('    ')
      expect(tokens).toHaveLength(1)
      expect(tokens[0].type).toBe('EOF')
    })

    test('tabs', () => {
      const tokens = scan('\t\t\t')
      expect(tokens).toHaveLength(1)
      expect(tokens[0].type).toBe('EOF')
    })

    test('consecutive newlines', () => {
      const tokens = scan('\n\n\n\n')
      expect(tokens).toHaveLength(1)
      expect(tokens[0].type).toBe('EOF')
    })

    test('between statements', () => {
      const tokens = scan('1\n\n2\n')
      expect(tokens).toHaveLength(3)
      expect(tokens[0].type).toBe('NUMBER')
      expect(tokens[1].type).toBe('NUMBER')
      expect(tokens[2].type).toBe('EOF')
    })
  })
})
