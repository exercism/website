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

describe('statements', () => {
  describe('expression', () => {
    test('number', () => {
      const { frames, error } = interpret('set x to 1')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 1 })
    })

    test('string', () => {
      const { frames } = interpret('set x to "hello there"')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 'hello there' })
    })

    describe('unary', () => {
      test('negation', () => {
        const { frames } = interpret('set x to !true')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: false })
      })

      test('minus', () => {
        const { frames } = interpret('set x to -3')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: -3 })
      })
    })

    describe('binary', () => {
      describe('arithmetic', () => {
        test('plus', () => {
          const { frames } = interpret('set x to 2 + 3')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 5 })
        })

        test('minus', () => {
          const { frames } = interpret('set x to 7 - 6')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 1 })
        })

        test('division', () => {
          const { frames } = interpret('set x to 20 / 5')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 4 })
        })

        test('multiplication', () => {
          const { frames } = interpret('set x to 4 * 2')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 8 })
        })

        test('remainder', () => {
          const { frames } = interpret('set x to 4 % 3')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 1 })
        })
      })

      describe('comparison', () => {
        test('equality with is - true', () => {
          const { frames, error } = interpret('set x to (2 is 2)')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })

        test('equality with equals - true', () => {
          const { frames } = interpret('set x to 2 equals 2')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })

        test('equality with is - false', () => {
          const { frames } = interpret('set x to (2 is "2")')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        test('equality with equals', () => {
          const { frames } = interpret('set x to 2 equals "2"')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        // TODO: Decide what syntax we want for this.
        test.skip('inequality', () => {
          const { frames } = interpret('set x to 2 != "2"')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })
      })

      describe('logical', () => {
        test('and', () => {
          const { frames } = interpret('set x to true and false')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        test('or', () => {
          const { frames } = interpret('set x to true or false')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })

        describe("truthiness doesn't exit", () => {
          test('and', () => {
            const { frames } = interpret('set x to true and "asd"')
            expect(frames).toBeArrayOfSize(1)
            expect(frames[0].status).toBe('ERROR')
          })

          test('or', () => {
            const { frames } = interpret('set x to false or 0')
            expect(frames).toBeArrayOfSize(1)
            expect(frames[0].status).toBe('ERROR')
          })
        })
      })

      describe('strings', () => {
        test.skip('plus', () => {
          const { frames } = interpret('set x to "sw" + "eet" ')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 'sweet' })
        })
      })
    })

    describe('assignment', () => {
      test('regular', () => {
        const { frames } = interpret(`
          set x to 2
          change x to 3
        `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: 2 })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({ x: 3 })
      })
    })
  })

  describe('variable', () => {
    test('declare and use', () => {
      const { frames } = interpret('set x to 2')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 2 })
    })

    test('errors if declared twice', () => {
      const { error, frames } = interpret(`
        set pos to 10
        set pos to 20
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[1].error!.category).toBe('RuntimeError')
      expect(frames[1].error!.type).toBe('VariableAlreadyDeclared')
    })

    test('declare and use', () => {
      const { frames } = interpret(`
        set x to 2
        set y to x + 1
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 2 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 2, y: 3 })
    })
  })

  describe('change', () => {
    test('changes variable correctly', () => {
      const { error, frames } = interpret(`
        set pos to 10
        change pos to 20
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].variables).toMatchObject({ pos: 10 })
      expect(frames[1].variables).toMatchObject({ pos: 20 })
    })

    test('errors if not declared', () => {
      const { error, frames } = interpret(`
        change pos to 20
      `)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].error!.category).toBe('RuntimeError')
      expect(frames[0].error!.type).toBe('VariableNotDeclared')
    })
  })

  describe('scope', () => {
    test('declared variable can be used in blocks', () => {
      const { error, frames } = interpret(`
        set pos to 10
        repeat 5 times do
          change pos to pos + 10
        end
      `)
      expect(frames).toBeArrayOfSize(7)
      expect(frames[6].variables).toMatchObject({ pos: 60 })
    })

    test('declared variable is persisted after repeat', () => {
      const { error, frames } = interpret(`
        set pos to 10
        repeat 5 times do
          change pos to pos + 10
        end
        change pos to pos + 10
      `)
      expect(frames).toBeArrayOfSize(8)
      expect(frames[7].variables).toMatchObject({ pos: 70 })
    })

    test('declared variable is persisted after if', () => {
      const { error, frames } = interpret(`
        set pos to 10
        if pos is 10 do
          change pos to pos + 10
        end
        change pos to pos + 5
      `)
      expect(frames).toBeArrayOfSize(4)
      expect(frames[0].variables).toMatchObject({ pos: 10 })
      expect(frames[1].variables).toMatchObject({ pos: 10 })
      // expect(frames[2].variables).toMatchObject({ pos: 20 })
      expect(frames[3].variables).toMatchObject({ pos: 25 })
    })
  })
  describe('creating function', () => {
    describe('without parameters', () => {
      test('define', () => {
        const { frames } = interpret(`
          function move {
            return 1
          }
        `)
        expect(frames).toBeEmpty()
      })

      describe('call', () => {
        test('single statement function', () => {
          const { frames } = interpret(`
            function move do
              return 1
            end
            set x to move()
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toBeEmpty()
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 1 })
        })
      })
    })

    describe('with parameters', () => {
      test('define', () => {
        const { frames } = interpret(`
          function move with x do
            return 1 + x
          end
        `)
        expect(frames).toBeEmpty()
      })

      describe('call', () => {
        test('single statement function', () => {
          const { frames } = interpret(`
            function move with x do
              return 1 + x
            end
            set x to move(2)
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 2 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 3 })
        })
      })
    })
  })

  describe('if', () => {
    test('without else', () => {
      const { frames } = interpret(`
        if true is true do
          set x to 2
        end
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 2 })
    })

    test('with else', () => {
      const { frames } = interpret(`
        if true is false do
          set x to 2
        else do
          set x to 3
        end
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 3 })
    })

    test('stacked', () => {
      const { frames } = interpret(`
        if true is false do
          set x to 2
        else if true is true do
          set x to 3
        else do
          set x to 4
        end
      `)
      expect(frames).toBeArrayOfSize(3)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toBeEmpty()
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 3 })
    })
    test('nested if', () => {
      const { error, frames } = interpret(`
        set x to 1
        if true is true do
          change x to 2
          if true is true do
            change x to 3
          end
        end
      `)
      expect(error).toBeNull()
      expect(frames).toBeArrayOfSize(5)
      frames.forEach((frame) => {
        expect(frame.status).toBe('SUCCESS')
      })
    })
    test('nested if/else', () => {
      const { error, frames } = interpret(`
        set x to 1
        if true is true do
          change x to 2
          if true is true do
            change x to 3
          end
        else do
          change x to 4
        end
      `)
      expect(error).toBeNull()
      expect(frames).toBeArrayOfSize(5)
      frames.forEach((frame) => {
        expect(frame.status).toBe('SUCCESS')
      })
    })
  })

  describe('repeat', () => {
    test('once', () => {
      const { error, frames } = interpret(`
        set x to 0
        repeat 1 times do
          change x to x + 1
        end
      `)
      expect(frames).toBeArrayOfSize(3)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 0 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 0 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 1 })
    })

    test('multiple times', () => {
      const { frames } = interpret(`
        set x to 0
        repeat 3 times do
          change x to x + 1
        end
      `)
      expect(frames).toBeArrayOfSize(5)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 0 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 0 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 1 })
      expect(frames[3].status).toBe('SUCCESS')
      expect(frames[3].variables).toMatchObject({ x: 2 })
      expect(frames[4].status).toBe('SUCCESS')
      expect(frames[4].variables).toMatchObject({ x: 3 })
    })
  })

  describe('block', () => {
    test('non-nested', () => {
      const { frames } = interpret(`
        do
          set x to 1
          set y to 2
        end
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 1 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 1, y: 2 })
    })

    test('nested', () => {
      const { frames } = interpret(`
        do
          set x to 1
          do
            set y to 2
          end
        end
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 1 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ y: 2 })
    })
  })
})

describe('frames', () => {
  describe('single statement', () => {
    test('literal', () => {
      const { frames } = interpret('log 125')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('log 125')
      expect(frames[0].error).toBeNil()
      expect(frames[0].variables).toBeEmpty()
    })

    test('call', () => {
      const echoFunction = (_interpreter: any, _n: any) => {}
      const context = {
        externalFunctions: [
          {
            name: 'echo',
            func: echoFunction,
            description: '',
          },
        ],
      }
      const { error, frames } = interpret('echo(1)', context)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('echo(1)')
      expect(frames[0].error).toBeNil()
      expect(frames[0].variables).toBeEmpty()
    })

    test('variable', () => {
      const { frames } = interpret('set x to 1')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('set x to 1')
      expect(frames[0].error).toBeNil()
      expect(frames[0].variables).toMatchObject({ x: 1 })
    })
  })

  describe('multiple statements', () => {
    test('multiple calls', () => {
      const context = {
        externalFunctions: [
          {
            name: 'echo',
            func: (_: any, n: any) => {},
            description: '',
          },
        ],
      }
      const { frames } = interpret(
        `
          echo(1)
          echo(2)
        `,
        context
      )
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].line).toBe(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('echo(1)')
      expect(frames[0].error).toBeNil()
      expect(frames[1].line).toBe(3)
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].code).toBe('echo(2)')
      expect(frames[1].error).toBeNil()
    })
  })

  test('no error', () => {
    const { frames, error } = interpret('log 125')
    expect(frames).not.toBeEmpty()
    expect(error).toBeNull()
  })
})

describe('timing', () => {
  describe('single statement', () => {
    test('success', () => {
      const context = {
        externalFunctions: [
          { name: 'echo', func: (_: any, _n: any) => {}, description: '' },
        ],
      }
      const { frames } = interpret('echo(1)', context)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].time).toBe(0)
    })
  })

  describe('multiple statements', () => {
    test('all successes', () => {
      const context = {
        externalFunctions: [
          { name: 'echo', func: (_: any, _n: any) => {}, description: '' },
        ],
      }
      const { frames } = interpret(
        `
          echo(1)
          echo(2)
        `,
        context
      )
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].time).toBe(0)
      expect(frames[1].time).toBe(1)
    })
  })

  describe('execution context', () => {
    test('from non-user code', () => {
      const advanceTimeFunction = (
        { fastForward }: ExecutionContext,
        n: number
      ) => fastForward(n)
      const context = {
        externalFunctions: [
          {
            name: 'advanceTime',
            func: advanceTimeFunction,
            description: '',
          },
        ],
      }
      const { frames } = interpret(
        `
          log 1
          advanceTime(20)
          log 2
        `,
        context
      )
      expect(frames).toBeArrayOfSize(3)
      expect(frames[0].time).toBe(0)
      expect(frames[1].time).toBe(1)
      expect(frames[2].time).toBe(22)
    })

    test('from user code is not possible', () => {
      const { frames } = interpret('fastForward(100)')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('ERROR')
      expect(frames[0].time).toBe(0)
    })

    test('manipulate state', () => {
      const state = { count: 10 }
      const incrementFunction = ({ state }: ExecutionContext) => {
        state.count++
      }
      const context = {
        externalFunctions: [
          {
            name: 'increment',
            func: incrementFunction,
            description: '',
          },
        ],
        state,
      }
      const { frames } = interpret('increment()', context)
      expect(state.count).toBe(11)

      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].time).toBe(0)
    })
  })
})

describe('evaluateFunction', () => {
  test('without arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move do
        return 1
      end
    `,
      {},
      'move'
    )
    expect(value).toBe(1)
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].result?.value.value).toBe(1)
  })

  test('with arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move with x, y do
        return x + y
      end
    `,
      {},
      'move',
      1,
      2
    )
    expect(value).toBe(3)
    expect(frames).toBeArrayOfSize(1)
  })

  // TODO: Add when dictionaries and arrays are back
  test.skip('with complex arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move with car, speeds do
        return car["x"] + speeds[1]
      end
    `,
      {},
      'move',
      { x: 2 },
      [4, 5, 6]
    )
    expect(value).toBe(7)
    expect(frames).toBeArrayOfSize(1)
  })

  test('idempotent - 1', () => {
    const code = `
      set x to 1
      function move do
        change x to x + 1
        return x
      end`
    const interpreter = new Interpreter(code, {
      languageFeatures: { allowGlobals: true },
    })
    interpreter.compile()
    const { value: value1 } = interpreter.evaluateFunction('move')
    const { value: value2 } = interpreter.evaluateFunction('move')
    expect(value1).toBe(2)
    expect(value2).toBe(2)
  })

  test('idempotent - 2', () => {
    const code = `
      set x to 1
      function move do
        change x to x + 1
        return x
      end
      move()
      move()
      `
    const { frames, error } = interpret(code, {
      languageFeatures: { allowGlobals: true },
    })
    expect(frames[6].variables.x).toBe(3)
  })

  // TODO: Work out all this syntax
  test.skip('full program', () => {
    const code = `
      function chooseEnemy with enemies do
        set maxRight to 0
        set rightmostEnemyId to null
      
        foreach enemy of enemies do
          if enemy["coords"][0] > maxRight do
            set maxRight to enemy["coords"][0]
            set rightmostEnemyId to enemy["id"]
          end
        end
      
        return rightmostEnemyId
      end
    `

    const poses = [
      { id: 1, coords: [2, 4] },
      { id: 2, coords: [3, 1] },
    ]
    const { value, frames } = evaluateFunction(code, {}, 'chooseEnemy', poses)
    expect(value).toBe(2)
    expect(frames).toBeArrayOfSize(11)
  })

  test.skip('twoFer', () => {
    const code = `
      function twoFer with name do
        if(name is "") do
          return "One for you, one for me."
        else do
          return "One for " + name + ", one for me."
        end
      end
    `

    const { value } = evaluateFunction(code, {}, 'twoFer', 'Alice')
    expect(value).toEqual('One for Alice, one for me.')
  })
})

describe('errors', () => {
  test('scanner', () => {
    const { frames, error } = interpret('let 123#')
    expect(frames).toBeEmpty()
    expect(error).not.toBeNull()
    expect(error!.category).toBe('SyntaxError')
    expect(error!.type).toBe('UnknownCharacter')
    expect(error!.context?.character).toBe('#')
  })

  test('parser', () => {
    const { frames, error } = interpret('"abc')
    expect(frames).toBeEmpty()
    expect(error).not.toBeNull()
    expect(error!.category).toBe('SyntaxError')
    expect(error!.type).toBe('MissingDoubleQuoteToTerminateString')
    expect(error!.context).toBeNull
  })

  describe('runtime', () => {
    describe('evaluateFunction', () => {
      test('first frame', () => {
        const { value, frames, error } = evaluateFunction(
          `
          function move do
            foo()
          end
        `,
          {},
          'move'
        )
        expect(value).toBeUndefined()
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(3)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].code).toBe('foo()')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('CouldNotFindFunction')
        expect(frames[0].error!.message).toBe('CouldNotFindFunction: name: foo')
        expect(error).toBeNull()
      })

      test('later frame', () => {
        const code = `
          function move do
            set x to 1
            set y to 2
            foo()
          end
        `
        const { value, frames, error } = evaluateFunction(code, {}, 'move')

        expect(value).toBeUndefined()
        expect(frames).toBeArrayOfSize(3)
        expect(frames[2].line).toBe(5)
        expect(frames[2].status).toBe('ERROR')
        expect(frames[2].code).toBe('foo()')
        expect(frames[2].error).not.toBeNull()
        expect(frames[2].error!.category).toBe('RuntimeError')
        expect(frames[2].error!.type).toBe('CouldNotFindFunction')
        expect(frames[2].error!.message).toBe('CouldNotFindFunction: name: foo')
        expect(error).toBeNull()
      })

      test('missing function', () => {
        const code = `
          function m0ve do
          end
        `
        const { value, frames, error } = evaluateFunction(code, {}, 'move')

        expect(value).toBeUndefined()
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(1)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('ExpectedFunctionNotFound')
        expect(frames[0].error!.message).toBe(
          'ExpectedFunctionNotFound: name: move'
        )
        expect(error).toBeNull()
      })

      test('incorrect args', () => {
        const code = `
          function move with foo do
          end
        `
        const { value, frames, error } = evaluateFunction(
          code,
          {},
          'move',
          1,
          2
        )

        expect(value).toBeUndefined()
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(1)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('ExpectedFunctionHasWrongArguments')
        expect(frames[0].error!.message).toBe(
          'ExpectedFunctionHasWrongArguments: name: move'
        )
        expect(error).toBeNull()
      })
    })
  })

  describe('interpret', () => {
    describe('call', () => {
      test('non-callable', () => {
        const { frames, error } = interpret('1()')
        expect(error).not.toBeNull()

        expect(error!.type).toBe('InvalidFunctionName')
      })

      test('forgetting brackets', () => {
        const echoFunction = (_interpreter: any, _n: any) => {}
        const context = {
          externalFunctions: [
            { name: 'echo', func: echoFunction, description: '' },
          ],
        }
        const { frames } = interpret('set x to echo', context)
        expect(frames[0].status).toBe('ERROR')
      })

      describe('arity', () => {
        describe('no optional parameters', () => {
          test('too many arguments', () => {
            const context = {
              externalFunctions: [
                {
                  name: 'echo',
                  func: (_: any) => {},
                  description: '',
                },
              ],
            }
            const { frames, error } = interpret('echo(1)', context)

            expect(frames).toBeArrayOfSize(1)
            expect(frames[0].line).toBe(1)
            expect(frames[0].status).toBe('ERROR')
            expect(frames[0].code).toBe('echo(1)')
            expect(frames[0].error).not.toBeNull()
            expect(frames[0].error!.category).toBe('RuntimeError')
            expect(frames[0].error!.type).toBe('TooManyArguments')
            expect(frames[0].error!.message).toBe(
              'TooManyArguments: arity: 0, numberOfArgs: 1'
            )
            expect(error).toBeNull()
          })

          test('too few arguments', () => {
            const context = {
              externalFunctions: [
                {
                  name: 'echo',
                  func: (_int: any, _: any) => {},
                  description: '',
                },
              ],
            }
            const { frames, error } = interpret('echo()', context)
            expect(frames).toBeArrayOfSize(1)
            expect(frames[0].line).toBe(1)
            expect(frames[0].status).toBe('ERROR')
            expect(frames[0].code).toBe('echo()')
            expect(frames[0].error).not.toBeNull()
            expect(frames[0].error!.category).toBe('RuntimeError')
            expect(frames[0].error!.type).toBe('TooFewArguments')
            expect(frames[0].error!.message).toBe(
              'TooFewArguments: arity: 1, numberOfArgs: 0'
            )
            expect(error).toBeNull()
          })
        })
      })

      describe('unknown function', () => {
        test('not misspelled', () => {
          const { frames, error } = interpret('foo()')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].line).toBe(1)
          expect(frames[0].status).toBe('ERROR')
          expect(frames[0].code).toBe('foo()')
          expect(frames[0].error).not.toBeNull()
          expect(frames[0].error!.category).toBe('RuntimeError')
          expect(frames[0].error!.type).toBe('CouldNotFindFunction')
          expect(frames[0].error!.message).toBe(
            'CouldNotFindFunction: name: foo'
          )
          expect(error).toBeNull()
        })

        test('misspelled', () => {
          const { frames, error } = interpret(`
            function foobar do
              return 1
            end

            foobor()
          `)
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].line).toBe(6)
          expect(frames[0].status).toBe('ERROR')
          expect(frames[0].code).toBe('foobor()')
          expect(frames[0].error).not.toBeNull()
          expect(frames[0].error!.message).toBe(
            'CouldNotFindFunctionWithSuggestion: name: foobor, suggestion: foobar'
          )
          expect(frames[0].error!.category).toBe('RuntimeError')
          expect(frames[0].error!.type).toBe(
            'CouldNotFindFunctionWithSuggestion'
          )
          expect(error).toBeNull()
        })
      })

      test('missing parentheses within set', () => {
        const context = {
          externalFunctions: [
            { name: 'y', func: (_: any) => {}, description: '' },
          ],
        }
        const { error, frames } = interpret(`set x to y`, context)
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(1)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].code).toBe('set x to y')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('MissingParenthesesForFunctionCall')
        expect(frames[0].error!.message).toBe(
          'MissingParenthesesForFunctionCall: name: y'
        )

        expect(error).toBeNull()
      })

      test('after success', () => {
        const { frames, error } = interpret(`
          log 123
          foo()
        `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].line).toBe(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].code).toBe('log 123')
        expect(frames[0].error).toBeNil()
        expect(frames[1].line).toBe(3)
        expect(frames[1].status).toBe('ERROR')
        expect(frames[1].code).toBe('foo()')
        expect(frames[1].error).not.toBeNull()
        expect(frames[1].error!.category).toBe('RuntimeError')
        expect(frames[1].error!.type).toBe('CouldNotFindFunction')
        expect(frames[1].error!.message).toBe('CouldNotFindFunction: name: foo')
        expect(error).toBeNull()
      })

      test('stop execution after error', () => {
        const { frames, error } = interpret(`
          foo()
          set x to 123
        `)
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(2)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].code).toBe('foo()')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('CouldNotFindFunction')
        expect(frames[0].error!.message).toBe('CouldNotFindFunction: name: foo')
        expect(error).toBeNull()
      })
    })
  })

  describe('suggestions', () => {
    test('function name differs by one letter', () => {
      const code = `
        function move do
        end
        m0ve()
      `
      const { frames, error } = interpret(code, {})
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].error).not.toBeNull()
      expect(frames[0].error!.context).toMatchObject({
        didYouMean: {
          function: 'move',
          variable: null,
        },
      })
    })

    // Recursion isn't supported in JikiScript (yet?)
    test.skip('recursive function name differs by one letter', () => {
      const code = `
        function move do
          m0ve()
        end
      `
      const { frames, error } = evaluateFunction(code, {}, 'move')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].error).not.toBeNull()
      expect(frames[0].error!.context).toMatchObject({
        didYouMean: {
          function: 'move',
          variable: null,
        },
      })
    })

    test('variable name differs by one letter', () => {
      const code = `set size to 23
                    set x to saize + 5`
      const { frames } = interpret(code, {})

      expect(frames).toBeArrayOfSize(2)
      expect(frames[1].error).not.toBeNull()
      expect(frames[1].error!.context).toMatchObject({
        didYouMean: {
          function: null,
          variable: 'size',
        },
      })
    })
  })
})

describe('context', () => {
  describe('wrap top-level statements', () => {
    // TODO: This test doesn't make a huge amount of sense to me.
    test.skip('wrap non-function statements', () => {
      const code = `
        function move with x, y do
          return x + y
        end

        set x to 1
        set y to 2
        move(x, y)
      `
      const { frames } = evaluateFunction(
        code,
        { wrapTopLevelStatements: true },
        'main'
      )
      expect(frames).toBeArrayOfSize(4)
      expect(frames[3].result?.value.value).toBe(3)
    })

    test("don't wrap function declarations", () => {
      const { value, frames } = evaluateFunction(
        `
        function move do
          return 1
        end
      `,
        {},
        'move'
      )
      expect(value).toBe(1)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].result?.value.value).toBe(1)
    })
  })
})
