import { scan } from '@/interpreter/scanner'
import { type TokenType } from '@/interpreter/token'

describe('single-character', () => {
  test.each([
    ['{', 'LEFT_BRACE'],
    ['[', 'LEFT_BRACKET'],
    ['(', 'LEFT_PAREN'],
    ['}', 'RIGHT_BRACE'],
    [']', 'RIGHT_BRACKET'],
    [')', 'RIGHT_PAREN'],
    [':', 'COLON'],
    [',', 'COMMA'],
    ['-', 'MINUS'],
    ['+', 'PLUS'],
    ['*', 'STAR'],
    ['/', 'SLASH'],
    ['=', 'EQUAL'],
    ['!', 'NOT'],
  ])("'%s' token", (source: string, expectedType: string) => {
    const tokens = scan(source)
    expect(tokens[0].type).toBe(expectedType as TokenType)
    expect(tokens[0].lexeme).toBe(source)
    expect(tokens[0].literal).toBeNull
  })
})

describe('one, two or three characters', () => {
  test.each([
    ['>', 'GREATER'],
    ['>=', 'GREATER_EQUAL'],
    ['<', 'LESS'],
    ['<=', 'LESS_EQUAL'],
    ['!=', 'INEQUALITY'],
    ['==', 'EQUALITY'],
  ])("'%s' token", (source: string, expectedType: string) => {
    const tokens = scan(source)
    expect(tokens[0].type).toBe(expectedType as TokenType)
    expect(tokens[0].lexeme).toBe(source)
    expect(tokens[0].literal).toBeNull
  })
})

describe('keyword', () => {
  test.each([
    ['and', 'AND'],
    ['continue', 'CONTINUE'],
    ['do', 'DO'],
    ['else', 'ELSE'],
    ['end', 'END'],
    ['false', 'FALSE'],
    ['for', 'FOR'],
    ['each', 'EACH'],
    ['function', 'FUNCTION'],
    ['if', 'IF'],
    ['in', 'IN'],
    ['null', 'NULL'],
    ['not', 'NOT'],
    ['or', 'OR'],
    ['repeat', 'REPEAT'],
    ['return', 'RETURN'],
    ['set', 'SET'],
    ['to', 'TO'],
    ['true', 'TRUE'],
    // ['while', 'WHILE'],
    ['with', 'WITH'],
    ['is', 'EQUALITY'],
    ['equals', 'EQUALITY'],
  ])("'%s' keyword", (source: string, expectedType: string) => {
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

describe('template literal', () => {
  test('empty', () => {
    const tokens = scan('``')
    expect(tokens.length).toBeGreaterThanOrEqual(2)
    expect(tokens[0].type).toBe('BACKTICK')
    expect(tokens[0].lexeme).toBe('`')
    expect(tokens[0].literal).toBeNull()
    expect(tokens[1].type).toBe('BACKTICK')
    expect(tokens[1].lexeme).toBe('`')
    expect(tokens[1].literal).toBeNull()
  })

  describe('text only', () => {
    test('single character', () => {
      const tokens = scan('`a`')
      expect(tokens.length).toBeGreaterThanOrEqual(3)
      expect(tokens[0].type).toBe('BACKTICK')
      expect(tokens[0].lexeme).toBe('`')
      expect(tokens[0].literal).toBeNull()
      expect(tokens[1].type).toBe('TEMPLATE_LITERAL_TEXT')
      expect(tokens[1].lexeme).toBe('a')
      expect(tokens[1].literal).toBe('a')
      expect(tokens[2].type).toBe('BACKTICK')
      expect(tokens[2].lexeme).toBe('`')
      expect(tokens[2].literal).toBeNull()
    })

    test('multiple characters', () => {
      const tokens = scan('`hello`')
      expect(tokens.length).toBeGreaterThanOrEqual(3)
      expect(tokens[0].type).toBe('BACKTICK')
      expect(tokens[0].lexeme).toBe('`')
      expect(tokens[0].literal).toBeNull()
      expect(tokens[1].type).toBe('TEMPLATE_LITERAL_TEXT')
      expect(tokens[1].lexeme).toBe('hello')
      expect(tokens[1].literal).toBe('hello')
      expect(tokens[2].type).toBe('BACKTICK')
      expect(tokens[2].lexeme).toBe('`')
      expect(tokens[2].literal).toBeNull()
    })

    test('containing whitespace', () => {
      const tokens = scan('` Good\tday! `')
      expect(tokens.length).toBeGreaterThanOrEqual(3)
      expect(tokens[0].type).toBe('BACKTICK')
      expect(tokens[0].lexeme).toBe('`')
      expect(tokens[0].literal).toBeNull()
      expect(tokens[1].type).toBe('TEMPLATE_LITERAL_TEXT')
      expect(tokens[1].lexeme).toBe(' Good\tday! ')
      expect(tokens[1].literal).toBe(' Good\tday! ')
      expect(tokens[2].type).toBe('BACKTICK')
      expect(tokens[2].lexeme).toBe('`')
      expect(tokens[2].literal).toBeNull()
    })

    test('containing number', () => {
      const tokens = scan('`Testing 1,2,3`')
      expect(tokens.length).toBeGreaterThanOrEqual(3)
      expect(tokens[0].type).toBe('BACKTICK')
      expect(tokens[0].lexeme).toBe('`')
      expect(tokens[0].literal).toBeNull()
      expect(tokens[1].type).toBe('TEMPLATE_LITERAL_TEXT')
      expect(tokens[1].lexeme).toBe('Testing 1,2,3')
      expect(tokens[1].literal).toBe('Testing 1,2,3')
      expect(tokens[2].type).toBe('BACKTICK')
      expect(tokens[2].lexeme).toBe('`')
      expect(tokens[2].literal).toBeNull()
    })
  })

  describe('placeholder only', () => {
    test('string', () => {
      const tokens = scan('`${"hello"}`')
      expect(tokens.length).toBeGreaterThanOrEqual(5)
      expect(tokens[0].type).toBe('BACKTICK')
      expect(tokens[0].lexeme).toBe('`')
      expect(tokens[0].literal).toBeNull()
      expect(tokens[1].type).toBe('DOLLAR_LEFT_BRACE')
      expect(tokens[1].lexeme).toBe('${')
      expect(tokens[1].literal).toBeNull()
      expect(tokens[2].type).toBe('STRING')
      expect(tokens[2].lexeme).toBe('"hello"')
      expect(tokens[2].literal).toBe('hello')
      expect(tokens[3].type).toBe('RIGHT_BRACE')
      expect(tokens[3].lexeme).toBe('}')
      expect(tokens[3].literal).toBeNull()
      expect(tokens[4].type).toBe('BACKTICK')
      expect(tokens[4].lexeme).toBe('`')
      expect(tokens[4].literal).toBeNull()
    })

    test('binary expression', () => {
      const tokens = scan('`${2*4}`')
      expect(tokens.length).toBeGreaterThanOrEqual(7)
      expect(tokens[0].type).toBe('BACKTICK')
      expect(tokens[0].lexeme).toBe('`')
      expect(tokens[0].literal).toBeNull()
      expect(tokens[1].type).toBe('DOLLAR_LEFT_BRACE')
      expect(tokens[1].lexeme).toBe('${')
      expect(tokens[1].literal).toBeNull()
      expect(tokens[2].type).toBe('NUMBER')
      expect(tokens[2].lexeme).toBe('2')
      expect(tokens[2].literal).toBe(2)
      expect(tokens[3].type).toBe('STAR')
      expect(tokens[3].lexeme).toBe('*')
      expect(tokens[3].literal).toBeNull()
      expect(tokens[4].type).toBe('NUMBER')
      expect(tokens[4].lexeme).toBe('4')
      expect(tokens[4].literal).toBe(4)
      expect(tokens[5].type).toBe('RIGHT_BRACE')
      expect(tokens[5].lexeme).toBe('}')
      expect(tokens[5].literal).toBeNull()
      expect(tokens[6].type).toBe('BACKTICK')
      expect(tokens[6].lexeme).toBe('`')
      expect(tokens[6].literal).toBeNull()
    })
  })

  test('text and placeholders', () => {
    const tokens = scan('`sum of ${2} * ${3} is ${"six"}`')
    expect(tokens.length).toBeGreaterThanOrEqual(5)
    expect(tokens[0].type).toBe('BACKTICK')
    expect(tokens[0].lexeme).toBe('`')
    expect(tokens[0].literal).toBeNull()
    expect(tokens[1].type).toBe('TEMPLATE_LITERAL_TEXT')
    expect(tokens[1].lexeme).toBe('sum of ')
    expect(tokens[1].literal).toBe('sum of ')
    expect(tokens[2].type).toBe('DOLLAR_LEFT_BRACE')
    expect(tokens[2].lexeme).toBe('${')
    expect(tokens[2].literal).toBeNull()
    expect(tokens[3].type).toBe('NUMBER')
    expect(tokens[3].lexeme).toBe('2')
    expect(tokens[3].literal).toBe(2)
    expect(tokens[4].type).toBe('RIGHT_BRACE')
    expect(tokens[4].lexeme).toBe('}')
    expect(tokens[4].literal).toBeNull()
    expect(tokens[5].type).toBe('TEMPLATE_LITERAL_TEXT')
    expect(tokens[5].lexeme).toBe(' * ')
    expect(tokens[5].literal).toBe(' * ')
    expect(tokens[6].type).toBe('DOLLAR_LEFT_BRACE')
    expect(tokens[6].lexeme).toBe('${')
    expect(tokens[6].literal).toBeNull()
    expect(tokens[7].type).toBe('NUMBER')
    expect(tokens[7].lexeme).toBe('3')
    expect(tokens[7].literal).toBe(3)
    expect(tokens[8].type).toBe('RIGHT_BRACE')
    expect(tokens[8].lexeme).toBe('}')
    expect(tokens[8].literal).toBeNull()
    expect(tokens[9].type).toBe('TEMPLATE_LITERAL_TEXT')
    expect(tokens[9].lexeme).toBe(' is ')
    expect(tokens[9].literal).toBe(' is ')
    expect(tokens[10].type).toBe('DOLLAR_LEFT_BRACE')
    expect(tokens[10].lexeme).toBe('${')
    expect(tokens[10].literal).toBeNull()
    expect(tokens[11].type).toBe('STRING')
    expect(tokens[11].lexeme).toBe('"six"')
    expect(tokens[11].literal).toBe('six')
    expect(tokens[12].type).toBe('RIGHT_BRACE')
    expect(tokens[12].lexeme).toBe('}')
    expect(tokens[12].literal).toBeNull()
  })

  test('binary expression', () => {
    const tokens = scan('`${2*4}`')
    expect(tokens.length).toBeGreaterThanOrEqual(7)
    expect(tokens[0].type).toBe('BACKTICK')
    expect(tokens[0].lexeme).toBe('`')
    expect(tokens[0].literal).toBeNull()
    expect(tokens[1].type).toBe('DOLLAR_LEFT_BRACE')
    expect(tokens[1].lexeme).toBe('${')
    expect(tokens[1].literal).toBeNull()
    expect(tokens[2].type).toBe('NUMBER')
    expect(tokens[2].lexeme).toBe('2')
    expect(tokens[2].literal).toBe(2)
    expect(tokens[3].type).toBe('STAR')
    expect(tokens[3].lexeme).toBe('*')
    expect(tokens[3].literal).toBeNull()
    expect(tokens[4].type).toBe('NUMBER')
    expect(tokens[4].lexeme).toBe('4')
    expect(tokens[4].literal).toBe(4)
    expect(tokens[5].type).toBe('RIGHT_BRACE')
    expect(tokens[5].lexeme).toBe('}')
    expect(tokens[5].literal).toBeNull()
    expect(tokens[6].type).toBe('BACKTICK')
    expect(tokens[6].lexeme).toBe('`')
    expect(tokens[6].literal).toBeNull()
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

describe('call', () => {
  test('without arguments', () => {
    const tokens = scan('move()')
    expect(tokens).toBeArrayOfSize(5)
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[1].type).toBe('LEFT_PAREN')
    expect(tokens[2].type).toBe('RIGHT_PAREN')
    expect(tokens[3].type).toBe('EOL')
    expect(tokens[4].type).toBe('EOF')
  })

  test('single string argument', () => {
    const tokens = scan('turn("left")')
    expect(tokens).toBeArrayOfSize(6)
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[1].type).toBe('LEFT_PAREN')
    expect(tokens[2].type).toBe('STRING')
    expect(tokens[3].type).toBe('RIGHT_PAREN')
    expect(tokens[4].type).toBe('EOL')
    expect(tokens[5].type).toBe('EOF')
  })

  test('single integer argument', () => {
    const tokens = scan('advance(5)')
    expect(tokens).toBeArrayOfSize(6)
    expect(tokens[0].type).toBe('IDENTIFIER')
    expect(tokens[1].type).toBe('LEFT_PAREN')
    expect(tokens[2].type).toBe('NUMBER')
    expect(tokens[3].type).toBe('RIGHT_PAREN')
    expect(tokens[4].type).toBe('EOL')
    expect(tokens[5].type).toBe('EOF')
  })
})

test('multiple lines', () => {
  const tokens = scan('move()\nturn("left")\nmove()')
  expect(tokens).toBeArrayOfSize(14)
  expect(tokens[0].type).toBe('IDENTIFIER')
  expect(tokens[1].type).toBe('LEFT_PAREN')
  expect(tokens[2].type).toBe('RIGHT_PAREN')
  expect(tokens[3].type).toBe('EOL')
  expect(tokens[4].type).toBe('IDENTIFIER')
  expect(tokens[5].type).toBe('LEFT_PAREN')
  expect(tokens[6].type).toBe('STRING')
  expect(tokens[7].type).toBe('RIGHT_PAREN')
  expect(tokens[8].type).toBe('EOL')
  expect(tokens[9].type).toBe('IDENTIFIER')
  expect(tokens[10].type).toBe('LEFT_PAREN')
  expect(tokens[11].type).toBe('RIGHT_PAREN')
  expect(tokens[12].type).toBe('EOL')
  expect(tokens[13].type).toBe('EOF')
})

test('location', () => {
  const tokens = scan('move()\nturn("left")')
  expect(tokens).toBeArrayOfSize(10)

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

  expect(tokens[3].location.line).toBe(1)
  expect(tokens[3].location.relative.begin).toBe(7)
  expect(tokens[3].location.relative.end).toBe(8)
  expect(tokens[3].location.absolute.begin).toBe(7)
  expect(tokens[3].location.absolute.end).toBe(8)

  expect(tokens[4].location.line).toBe(2)
  expect(tokens[4].location.relative.begin).toBe(1)
  expect(tokens[4].location.relative.end).toBe(5)
  expect(tokens[4].location.absolute.begin).toBe(8)
  expect(tokens[4].location.absolute.end).toBe(12)

  expect(tokens[5].location.line).toBe(2)
  expect(tokens[5].location.relative.begin).toBe(5)
  expect(tokens[5].location.relative.end).toBe(6)
  expect(tokens[5].location.absolute.begin).toBe(12)
  expect(tokens[5].location.absolute.end).toBe(13)

  expect(tokens[6].location.line).toBe(2)
  expect(tokens[6].location.relative.begin).toBe(6)
  expect(tokens[6].location.relative.end).toBe(12)
  expect(tokens[6].location.absolute.begin).toBe(13)
  expect(tokens[6].location.absolute.end).toBe(19)

  expect(tokens[7].location.line).toBe(2)
  expect(tokens[7].location.relative.begin).toBe(12)
  expect(tokens[7].location.relative.end).toBe(13)
  expect(tokens[7].location.absolute.begin).toBe(19)
  expect(tokens[7].location.absolute.end).toBe(20)
})

describe('error', () => {
  describe('token', () => {
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
      expect(tokens).toHaveLength(5)
      expect(tokens[0].type).toBe('NUMBER')
      expect(tokens[1].type).toBe('EOL')
      expect(tokens[2].type).toBe('NUMBER')
      expect(tokens[3].type).toBe('EOL')
      expect(tokens[4].type).toBe('EOF')
    })
  })
})

describe('synthetic', () => {
  describe('EOL', () => {
    describe('not added', () => {
      test('empty line', () => {
        const tokens = scan('')
        expect(tokens).toBeArrayOfSize(1)
        expect(tokens[0].type).toBe('EOF')
      })

      test('before first statement', () => {
        const tokens = scan('\n1\n')
        expect(tokens).toHaveLength(3)
        expect(tokens[0].type).toBe('NUMBER')
        expect(tokens[1].type).toBe('EOL')
        expect(tokens[2].type).toBe('EOF')
      })

      test('between statements', () => {
        const tokens = scan('1\n\n2\n')
        expect(tokens).toHaveLength(5)
        expect(tokens[0].type).toBe('NUMBER')
        expect(tokens[1].type).toBe('EOL')
        expect(tokens[2].type).toBe('NUMBER')
        expect(tokens[3].type).toBe('EOL')
        expect(tokens[4].type).toBe('EOF')
      })
    })

    describe('added', () => {
      describe('single statement', () => {
        test('ending with newline', () => {
          const tokens = scan('1\n')
          expect(tokens).toBeArrayOfSize(3)
          expect(tokens[0].type).toBe('NUMBER')
          expect(tokens[1].type).toBe('EOL')
          expect(tokens[2].type).toBe('EOF')
        })

        test('not ending with newline', () => {
          const tokens = scan('1')
          expect(tokens).toBeArrayOfSize(3)
          expect(tokens[0].type).toBe('NUMBER')
          expect(tokens[1].type).toBe('EOL')
          expect(tokens[2].type).toBe('EOF')
        })
      })

      describe('multiple statements', () => {
        test('ending with newline', () => {
          const tokens = scan('1\n2\n')
          expect(tokens).toBeArrayOfSize(5)
          expect(tokens[0].type).toBe('NUMBER')
          expect(tokens[1].type).toBe('EOL')
          expect(tokens[2].type).toBe('NUMBER')
          expect(tokens[3].type).toBe('EOL')
          expect(tokens[4].type).toBe('EOF')
        })

        test('last statement not ending with newline', () => {
          const tokens = scan('1\n2')
          expect(tokens).toBeArrayOfSize(5)
          expect(tokens[0].type).toBe('NUMBER')
          expect(tokens[1].type).toBe('EOL')
          expect(tokens[2].type).toBe('NUMBER')
          expect(tokens[3].type).toBe('EOL')
          expect(tokens[4].type).toBe('EOF')
        })
      })
    })
  })
})
