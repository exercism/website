import {
  Interpreter,
  interpretJavaScript as interpret,
  evaluateJavaScriptFunction as evaluateFunction,
} from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'

describe('statements', () => {
  describe('expression', () => {
    test('number', () => {
      const { frames, error } = interpret('let x = 1')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 1 })
    })

    test('string', () => {
      const { frames } = interpret('let x = "hello there"')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 'hello there' })
    })

    describe('unary', () => {
      test('negation', () => {
        const { frames } = interpret('let x = !true')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: false })
      })

      test('minus', () => {
        const { frames } = interpret('let x = -3')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: -3 })
      })

      describe('increment', () => {
        test('variable', () => {
          const { frames } = interpret(`
            let x = 3
            x++
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 3 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 4 })
        })

        test('array', () => {
          const { frames } = interpret(`
            let x = [1,2]
            x[1]++
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: [1, 2] })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: [1, 3] })
        })

        test('dictionary', () => {
          const { frames } = interpret(`
            let x = {"count":1}
            x["count"]++
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: { count: 1 } })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: { count: 2 } })
        })
      })

      describe('decrement', () => {
        test('variable', () => {
          const { frames } = interpret(`
            let x = 3
            x--
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 3 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 2 })
        })

        test('array', () => {
          const { frames } = interpret(`
            let x = [1,2]
            x[1]--
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: [1, 2] })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: [1, 1] })
        })

        test('dictionary', () => {
          const { frames } = interpret(`
            let x = {"count":1}
            x["count"]--
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: { count: 1 } })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: { count: 0 } })
        })
      })
    })

    describe('binary', () => {
      describe('arithmetic', () => {
        test('plus', () => {
          const { frames } = interpret('let x = 2 + 3')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 5 })
        })

        test('minus', () => {
          const { frames } = interpret('let x = 7 - 6')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 1 })
        })

        test('division', () => {
          const { frames } = interpret('let x = 20 / 5')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 4 })
        })

        test('multiplication', () => {
          const { frames } = interpret('let x = 4 * 2')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 8 })
        })
      })

      describe('comparison', () => {
        test('equality', () => {
          const { frames } = interpret('let x = 2 == "2"')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })

        test('strict equality', () => {
          const { frames, error } = interpret('let x = 2 === "2"')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        test('inequality', () => {
          const { frames } = interpret('let x = 2 != "2"')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        test('strict inequality', () => {
          const { frames } = interpret('let x = 2 !== "2"')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })
      })

      describe('logical', () => {
        test('and', () => {
          const { frames } = interpret('let x = true and false')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        test('&&', () => {
          const { frames } = interpret('let x = true && false')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: false })
        })

        test('or', () => {
          const { frames } = interpret('let x = true or false')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })

        test('&&', () => {
          const { frames } = interpret('let x = true || false')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: true })
        })

        describe('truthiness', () => {
          describe('enabled', () => {
            test('and', () => {
              const { frames } = interpret('let x = [] and true', {
                languageFeatures: { truthiness: 'ON' },
              })
              expect(frames).toBeArrayOfSize(1)
              expect(frames[0].status).toBe('SUCCESS')
              expect(frames[0].variables).toMatchObject({ x: true })
            })

            test('or', () => {
              const { frames } = interpret('let x = 0 or false', {
                languageFeatures: { truthiness: 'ON' },
              })
              expect(frames).toBeArrayOfSize(1)
              expect(frames[0].status).toBe('SUCCESS')
              expect(frames[0].variables).toMatchObject({ x: false })
            })
          })

          describe('disabled', () => {
            test('and', () => {
              const { frames } = interpret('let x = true and []', {
                languageFeatures: { truthiness: 'OFF' },
              })
              expect(frames).toBeArrayOfSize(1)
              expect(frames[0].status).toBe('ERROR')
            })

            test('or', () => {
              const { frames } = interpret('let x = false or 0', {
                languageFeatures: { truthiness: 'OFF' },
              })
              expect(frames).toBeArrayOfSize(1)
              expect(frames[0].status).toBe('ERROR')
            })
          })
        })
      })

      describe('strings', () => {
        test('plus', () => {
          const { frames } = interpret('let x = "sw" + "eet" ')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 'sweet' })
        })
      })

      describe('template literals', () => {
        test('text only', () => {
          const { frames } = interpret('let x = `hello`')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 'hello' })
        })

        test('placeholder only', () => {
          const { frames } = interpret('let x = `${3*4}`')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: '12' })
        })

        test('string', () => {
          const { frames } = interpret('let x = `hello ${"there"}`')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 'hello there' })
        })

        test('variable', () => {
          const { frames } = interpret(`
            let x = 1
            let y = \`x is \${x}\`
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 1 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 1, y: 'x is 1' })
        })

        test('expression', () => {
          const { frames } = interpret('let x = `2 + 3 = ${2 + 3}`')
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: '2 + 3 = 5' })
        })

        test('complex', () => {
          const { frames } = interpret(
            'let x = `${2} + ${"three"} = ${2 + 9 / 3}`'
          )
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: '2 + three = 5' })
        })
      })
    })

    describe('ternary', () => {
      test('then branch', () => {
        const { frames } = interpret('let x = true ? 1 : 2')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: 1 })
      })

      test('else branch', () => {
        const { frames } = interpret('let x = false ? 1 : 2')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: 2 })
      })

      test('nested', () => {
        const { frames } = interpret(
          'let x = false ? 1 : false ? 2 : true ? 3 : 4'
        )
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: 3 })
      })
    })

    describe('get', () => {
      describe('dictionary', () => {
        test('single field', () => {
          const { frames } = interpret(`
            let movie = {"title": "The Matrix"}
            let title = movie["title"]
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({
            movie: { title: 'The Matrix' },
          })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({
            movie: { title: 'The Matrix' },
            title: 'The Matrix',
          })
        })

        test('chained', () => {
          const { frames } = interpret(`
            let movie = {"director": {"name": "Peter Jackson"}}
            let name = movie["director"]["name"]
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({
            movie: { director: { name: 'Peter Jackson' } },
          })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({
            movie: { director: { name: 'Peter Jackson' } },
            name: 'Peter Jackson',
          })
        })

        describe('array', () => {
          test('single index', () => {
            const { frames } = interpret(`
              let scores = [7, 3, 10]
              let latest = scores[2]
            `)
            expect(frames).toBeArrayOfSize(2)
            expect(frames[0].status).toBe('SUCCESS')
            expect(frames[0].variables).toMatchObject({
              scores: [7, 3, 10],
            })
            expect(frames[1].status).toBe('SUCCESS')
            expect(frames[1].variables).toMatchObject({
              scores: [7, 3, 10],
              latest: 10,
            })
          })

          test('chained', () => {
            const { frames } = interpret(`
              let scoreMinMax = [[3, 7], [1, 6]]
              let secondMin = scoreMinMax[1][0]
            `)
            expect(frames).toBeArrayOfSize(2)
            expect(frames[0].status).toBe('SUCCESS')
            expect(frames[0].variables).toMatchObject({
              scoreMinMax: [
                [3, 7],
                [1, 6],
              ],
            })
            expect(frames[1].status).toBe('SUCCESS')
            expect(frames[1].variables).toMatchObject({
              scoreMinMax: [
                [3, 7],
                [1, 6],
              ],
              secondMin: 1,
            })
          })
        })
      })
    })

    describe('set', () => {
      describe('dictionary', () => {
        test('single field', () => {
          const { frames } = interpret(`
            let movie = {"title": "The Matrix"}
            movie["title"] = "Gladiator"
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({
            movie: { title: 'The Matrix' },
          })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({
            movie: { title: 'Gladiator' },
          })
        })

        test('chained', () => {
          const { frames } = interpret(`
            let movie = {"director": {"name": "Peter Jackson"}}
            movie["director"]["name"] = "James Cameron"
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({
            movie: { director: { name: 'Peter Jackson' } },
          })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({
            movie: { director: { name: 'James Cameron' } },
          })
        })
      })

      describe('array', () => {
        test('single index', () => {
          const { frames } = interpret(`
            let scores = [7, 3, 10]
            scores[2] = 5
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({
            scores: [7, 3, 10],
          })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({
            scores: [7, 3, 5],
          })
        })

        test('chained', () => {
          const { frames } = interpret(`
            let scoreMinMax = [[3, 7], [1, 6]]
            scoreMinMax[1][0] = 4
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({
            scoreMinMax: [
              [3, 7],
              [1, 6],
            ],
          })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({
            scoreMinMax: [
              [3, 7],
              [4, 6],
            ],
          })
        })
      })
    })

    describe('assignment', () => {
      test('regular', () => {
        const { frames } = interpret(`
          let x = 2
          x = 3
        `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ x: 2 })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({ x: 3 })
      })

      describe('compound', () => {
        test('plus', () => {
          const { frames } = interpret(`
            let x = 2
            x += 3
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 2 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 5 })
        })

        test('minus', () => {
          const { frames } = interpret(`
            let x = 2
            x -= 3
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 2 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: -1 })
        })

        test('multiply', () => {
          const { frames } = interpret(`
            let x = 2
            x *= 3
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 2 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 6 })
        })

        test('divide', () => {
          const { frames } = interpret(`
            let x = 6
            x /= 3
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 6 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 2 })
        })
      })
    })
  })

  describe('variable', () => {
    test('declare and use', () => {
      const { frames } = interpret('let x = 2')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 2 })
    })

    test('declare and use', () => {
      const { frames } = interpret(`
        let x = 2
        let y = x + 1
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 2 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 2, y: 3 })
    })
  })

  describe('function', () => {
    describe('without parameters', () => {
      test('define', () => {
        const { frames } = interpret(`
          function move() {
            return 1
          }
        `)
        expect(frames).toBeEmpty()
      })

      describe('call', () => {
        test('single statement function', () => {
          const { frames } = interpret(`
            function move() {
              return 1
            }
            let x = move()
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
          function move(x) {
            return 1 + x
          }
        `)
        expect(frames).toBeEmpty()
      })

      describe('call', () => {
        test('single statement function', () => {
          const { frames } = interpret(`
            function move(x) {
              return 1 + x
            }
            let x = move(2)
          `)
          expect(frames).toBeArrayOfSize(2)
          expect(frames[0].status).toBe('SUCCESS')
          expect(frames[0].variables).toMatchObject({ x: 2 })
          expect(frames[1].status).toBe('SUCCESS')
          expect(frames[1].variables).toMatchObject({ x: 3 })
        })

        describe('default parameter', () => {
          test("don't pass in value", () => {
            const { frames } = interpret(`
              function move(x = 10) {
                return 1 + x
              }
              let x = move()
            `)
            expect(frames).toBeArrayOfSize(2)
            expect(frames[0].status).toBe('SUCCESS')
            expect(frames[0].variables).toMatchObject({ x: 10 })
            expect(frames[1].status).toBe('SUCCESS')
            expect(frames[1].variables).toMatchObject({ x: 11 })
          })

          test('pass in value', () => {
            const { frames } = interpret(`
              function move(x = 10) {
                return 1 + x
              }
              let x = move(2)
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
  })

  describe('if', () => {
    test('without else', () => {
      const { frames } = interpret(`
        if (true) {
          let x = 2
        }
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 2 })
    })

    test('with else', () => {
      const { frames } = interpret(`
        if (false) {
          let x = 2
        }
        else {
          let x = 3
        }
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 3 })
    })

    test('nested', () => {
      const { frames } = interpret(`
        if (false) {
          let x = 2
        }
        else if (true) {
          let x = 3
        }
        else {
          let x = 4
        }
      `)
      expect(frames).toBeArrayOfSize(3)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toBeEmpty()
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 3 })
    })
  })

  describe('while', () => {
    test('once', () => {
      const { frames } = interpret(`
        let x = 1
        while (x > 0) {
          x = x - 1
        }
      `)
      expect(frames).toBeArrayOfSize(4)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 1 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 1 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 0 })
      expect(frames[3].status).toBe('SUCCESS')
      expect(frames[3].variables).toMatchObject({ x: 0 })
    })

    test('multiple times', () => {
      const { frames } = interpret(`
        let x = 3
        while (x > 0) {
          x = x - 1
        }
      `)
      expect(frames).toBeArrayOfSize(8)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 3 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 3 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 2 })
      expect(frames[3].status).toBe('SUCCESS')
      expect(frames[3].variables).toMatchObject({ x: 2 })
      expect(frames[4].status).toBe('SUCCESS')
      expect(frames[4].variables).toMatchObject({ x: 1 })
      expect(frames[5].status).toBe('SUCCESS')
      expect(frames[5].variables).toMatchObject({ x: 1 })
      expect(frames[6].status).toBe('SUCCESS')
      expect(frames[6].variables).toMatchObject({ x: 0 })
      expect(frames[7].status).toBe('SUCCESS')
      expect(frames[7].variables).toMatchObject({ x: 0 })
    })
  })

  describe('do/while', () => {
    test('once', () => {
      const { frames } = interpret(`
        let x = 2
        do {
          x = x - 1
        }
        while (x > 1)
      `)
      expect(frames).toBeArrayOfSize(3)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 2 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 1 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 1 })
    })

    test('multiple times', () => {
      const { frames } = interpret(`
        let x = 3
        do {
          x = x - 1
        }
        while (x > 0)
      `)
      expect(frames).toBeArrayOfSize(7)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 3 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 2 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[2].variables).toMatchObject({ x: 2 })
      expect(frames[3].status).toBe('SUCCESS')
      expect(frames[3].variables).toMatchObject({ x: 1 })
      expect(frames[4].status).toBe('SUCCESS')
      expect(frames[4].variables).toMatchObject({ x: 1 })
      expect(frames[5].status).toBe('SUCCESS')
      expect(frames[5].variables).toMatchObject({ x: 0 })
      expect(frames[6].status).toBe('SUCCESS')
      expect(frames[6].variables).toMatchObject({ x: 0 })
    })
  })

  describe('foreach', () => {
    test('empty iterable', () => {
      const echos: string[] = []
      const context = {
        externalFunctions: [
          {
            name: 'echo',
            func: (_: any, n: any) => {
              echos.push(n.toString())
            },
            description: '',
          },
        ],
      }

      const { frames } = interpret(
        `
        for (let num of []) {
          echo(num)
        }
        `,
        context
      )
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(echos).toBeEmpty()
    })

    test('multiple times', () => {
      const echos: string[] = []
      const context = {
        externalFunctions: [
          {
            name: 'echo',
            func: (_: any, n: any) => {
              echos.push(n.toString())
            },
            description: '',
          },
        ],
      }

      const { frames } = interpret(
        `
          for (let num of [1, 2, 3]) {
            echo(num)
          }
        `,
        context
      )
      expect(frames).toBeArrayOfSize(6)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ num: 1 })
      expect(frames[2].status).toBe('SUCCESS')
      expect(frames[3].status).toBe('SUCCESS')
      expect(frames[3].variables).toMatchObject({ num: 2 })
      expect(frames[4].status).toBe('SUCCESS')
      expect(frames[5].status).toBe('SUCCESS')
      expect(frames[5].variables).toMatchObject({ num: 3 })
      expect(echos).toEqual(['1', '2', '3'])
    })
  })

  describe('block', () => {
    test('non-nested', () => {
      const { frames } = interpret(`
        {
          let x = 1
          let y = 2
        }
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].variables).toMatchObject({ x: 1 })
      expect(frames[1].status).toBe('SUCCESS')
      expect(frames[1].variables).toMatchObject({ x: 1, y: 2 })
    })

    test('nested', () => {
      const { frames } = interpret(`
        {
          let x = 1
          {
            let y = 2
          }
        }
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
      const { frames } = interpret('125')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('125')
      expect(frames[0].error).toBeNil()
      expect(frames[0].variables).toBeEmpty()
    })

    test('call', () => {
      const echoFunction = (_interpreter: any, _n: any) => {}
      const context = {
        externalFunctions: [
          { name: 'echo', func: echoFunction, description: '' },
        ],
      }
      const { frames } = interpret('echo(1)', context)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('echo(1)')
      expect(frames[0].error).toBeNil()
      expect(frames[0].variables).toBeEmpty()
    })

    test('variable', () => {
      const { frames } = interpret('let x = 1')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('let x = 1')
      expect(frames[0].error).toBeNil()
      expect(frames[0].variables).toMatchObject({ x: 1 })
    })

    test('constant', () => {
      const { frames } = interpret('const x = 1')
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].line).toBe(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(frames[0].code).toBe('const x = 1')
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
    const { frames, error } = interpret('125')
    expect(frames).not.toBeEmpty()
    expect(error).toBeNull()
  })
})

describe('timing', () => {
  describe('single statement', () => {
    test('success', () => {
      const context = {
        externalFunctions: [{ name: 'echo', func: () => {}, description: '' }],
      }
      const { frames } = interpret('echo(1)', context)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].time).toBe(0)
    })

    test('error', () => {
      const context = {
        externalFunctions: [{ name: 'echo', func: () => {}, description: '' }],
      }
      const { frames } = interpret('127()', context)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].time).toBe(0)
    })
  })

  describe('multiple statements', () => {
    test('all successes', () => {
      const context = {
        externalFunctions: [
          { name: 'echo', func: (_i: any, _n: any) => {}, description: '' },
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
          1
          advanceTime(20)
          2
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
          { name: 'increment', func: incrementFunction, description: '' },
        ],
        state: state,
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
      function move() {
        return 1
      }
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
      function move(x, y) {
        return x + y
      }
    `,
      {},
      'move',
      1,
      2
    )
    expect(value).toBe(3)
    expect(frames).toBeArrayOfSize(1)
  })

  test('with complex arguments', () => {
    const { value, frames } = evaluateFunction(
      `
      function move(car, speeds) {
        return car["x"] + speeds[1]
      }
    `,
      {},
      'move',
      { x: 2 },
      [4, 5, 6]
    )
    expect(value).toBe(7)
    expect(frames).toBeArrayOfSize(1)
  })

  test('idempotent', () => {
    const code = `
      let x = 1
      function move() {
        x = x + 1
        return x
      }`
    const interpreter = new Interpreter(code, {})
    interpreter.compile()
    const { value: value1 } = interpreter.evaluateFunction('move')
    const { value: value2 } = interpreter.evaluateFunction('move')
    expect(value1).toBe(2)
    expect(value2).toBe(2)
  })

  test('full program', () => {
    const code = `
      function chooseEnemy(enemies) {
        let maxRight = 0
        let rightmostEnemyId = null
      
        for (let enemy of enemies) {
          if (enemy["coords"][0] > maxRight) {
            maxRight = enemy["coords"][0]
            rightmostEnemyId = enemy["id"]
          }
        }
      
        return rightmostEnemyId
      }
    `

    const poses = [
      { id: 1, coords: [2, 4] },
      { id: 2, coords: [3, 1] },
    ]
    const { value, frames } = evaluateFunction(code, {}, 'chooseEnemy', poses)
    expect(value).toBe(2)
    expect(frames).toBeArrayOfSize(11)
  })

  test('twoFer', () => {
    const code = `
      function twoFer(name) {
        if(name == "") {
          return "One for you, one for me."
        }
        else {
          return "One for " + name + ", one for me."
        }
      }
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

  test('resolver', () => {
    const { frames, error } = interpret('return 1')
    expect(frames).toBeEmpty()
    expect(error).not.toBeNull()
    expect(error!.category).toBe('SemanticError')
    expect(error!.type).toBe('TopLevelReturn')
    expect(error!.context).toBeNull
  })

  describe('runtime', () => {
    describe('evaluateFunction', () => {
      test('first frame', () => {
        const { value, frames, error } = evaluateFunction(
          `
          function move() {
            foo()
          }
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
        expect(frames[0].error!.type).toBe('CouldNotFindFunctionWithName')
        expect(error).toBeNull()
      })

      test('later frame', () => {
        const code = `
          function move() {
            let x = 1
            let y = 2
            foo()
          }
        `
        const { value, frames, error } = evaluateFunction(code, {}, 'move')

        expect(value).toBeUndefined()
        expect(frames).toBeArrayOfSize(3)
        expect(frames[2].line).toBe(5)
        expect(frames[2].status).toBe('ERROR')
        expect(frames[2].code).toBe('foo()')
        expect(frames[2].error).not.toBeNull()
        expect(frames[2].error!.category).toBe('RuntimeError')
        expect(frames[2].error!.type).toBe('CouldNotFindFunctionWithName')
        expect(error).toBeNull()
      })
    })
  })

  describe('interpret', () => {
    describe('call', () => {
      test('non-callable', () => {
        const { frames, error } = interpret('1()')
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(1)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].code).toBe('1()')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('NonCallableTarget')
        expect(error).toBeNull()
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
            const { frames, error } = interpret('echo(1, 2)', context)
            expect(frames).toBeArrayOfSize(1)
            expect(frames[0].line).toBe(1)
            expect(frames[0].status).toBe('ERROR')
            expect(frames[0].code).toBe('echo(1, 2)')
            expect(frames[0].error).not.toBeNull()
            expect(frames[0].error!.category).toBe('RuntimeError')
            expect(frames[0].error!.type).toBe('TooManyArguments')
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
            expect(error).toBeNull()
          })

          // These tests don't make sense.
          describe.skip('with optional parameters', () => {
            test('too many arguments', () => {
              const context = {
                externalFunctions: [
                  {
                    name: 'echo',
                    func: () => {},
                    description: '',
                  },
                ],
              }
              const { frames, error } = interpret(
                `
                function echo(a, b, c, d = 5) {
                }
                echo(1, 2, 3, 4)
              `,
                context
              )
              expect(frames).toBeArrayOfSize(1)
              expect(frames[0].line).toBe(1)
              expect(frames[0].status).toBe('ERROR')
              expect(frames[0].code).toBe('echo(1, 2, 3, 4)')
              expect(frames[0].error).not.toBeNull()
              expect(frames[0].error!.category).toBe('RuntimeError')
              expect(frames[0].error!.type).toBe(
                'InvalidNumberOfArgumentsWithOptionalArguments'
              )
              expect(error).toBeNull()
            })

            test.skip('too few arguments', () => {
              const context = {
                externalFunctions: {
                  echo: () => {},
                },
              }
              const { frames, error } = interpret('echo(1)', context)
              expect(frames).toBeArrayOfSize(1)
              expect(frames[0].line).toBe(1)
              expect(frames[0].status).toBe('ERROR')
              expect(frames[0].code).toBe('echo(1)')
              expect(frames[0].error).not.toBeNull()
              expect(frames[0].error!.category).toBe('RuntimeError')
              expect(frames[0].error!.type).toBe(
                'InvalidNumberOfArgumentsWithOptionalArguments'
              )
              expect(error).toBeNull()
            })
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
          expect(frames[0].error!.type).toBe('CouldNotFindFunctionWithName')
          expect(error).toBeNull()
        })

        test('misspelled', () => {
          const { frames, error } = interpret(`
            function foobar() {
              return 1
            }

            foobor()
          `)
          expect(frames).toBeArrayOfSize(1)
          expect(frames[0].line).toBe(6)
          expect(frames[0].status).toBe('ERROR')
          expect(frames[0].code).toBe('foobor()')
          expect(frames[0].error).not.toBeNull()
          expect(frames[0].error!.message).toBe(
            "We don't know what `foobor` means. Maybe you meant to use the `foobar` function instead?"
          )
          expect(frames[0].error!.category).toBe('RuntimeError')
          expect(frames[0].error!.type).toBe(
            'CouldNotFindFunctionWithNameSuggestion'
          )
          expect(error).toBeNull()
        })
      })

      test('missing parentheses', () => {
        const { frames, error } = interpret(`
            function foo() {
              return 1
            }

            foo
          `)
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(6)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].code).toBe('foo')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.message).toBe(
          'Did you forget the parenthesis when trying to call the function?'
        )
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('MissingParenthesesForFunctionCall')
        expect(error).toBeNull()
      })

      test('after success', () => {
        const { frames, error } = interpret(`
          123
          foo()
        `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].line).toBe(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].code).toBe('123')
        expect(frames[0].error).toBeNil()
        expect(frames[1].line).toBe(3)
        expect(frames[1].status).toBe('ERROR')
        expect(frames[1].code).toBe('foo()')
        expect(frames[1].error).not.toBeNull()
        expect(frames[1].error!.category).toBe('RuntimeError')
        expect(frames[1].error!.type).toBe('CouldNotFindFunctionWithName')
        expect(error).toBeNull()
      })

      test('stop execution after error', () => {
        const { frames, error } = interpret(`
          foo()
          123
        `)
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].line).toBe(2)
        expect(frames[0].status).toBe('ERROR')
        expect(frames[0].code).toBe('foo()')
        expect(frames[0].error).not.toBeNull()
        expect(frames[0].error!.category).toBe('RuntimeError')
        expect(frames[0].error!.type).toBe('CouldNotFindFunctionWithName')
        expect(error).toBeNull()
      })
    })
  })

  describe('suggestions', () => {
    test('function name differs by one letter', () => {
      const code = `
        function move() {
          m0ve()
        }
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
      const code = 'let size = 23'
      const { frames } = evaluateFunction(code, {}, 'saize + 2')

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
    // This test doesn't make a huge amount of sense to me.
    // as main doesn't actually return
    test.skip('wrap non-function statements', () => {
      const code = `
        function move(x, y) {
          return x + y
        }

        let x = 1
        let y = 2
        move(x, y)
      `
      const { value, frames } = evaluateFunction(
        code,
        { wrapTopLevelStatements: true },
        'main'
      )
      expect(value).toBe(3)
      expect(frames).toBeArrayOfSize(4)
      expect(frames[3].result?.value.value).toBe(3)
    })

    test("don't wrap function declarations", () => {
      const { value, frames } = evaluateFunction(
        `
        function move() {
          return 1
        }
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
