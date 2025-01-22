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

describe.skip('arrays', () => {
  describe('set', () => {
    test('single index', () => {
      const { frames } = interpret(`
      set scores to [7, 3, 10]
      set scores[2] to 5
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
      set scoreMinMax to [[3, 7], [1, 6]]
      set scoreMinMax[1][0] to 4
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

  describe('get', () => {
    test('single index', () => {
      const { frames } = interpret(`
      set scores to [7, 3, 10]
      set latest to scores[2]
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
      set scoreMinMax to [[3, 7], [1, 6]]
      set secondMin to scoreMinMax[1][0]
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

  describe.skip('foreach', () => {
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
            foreach num in [] do
              echo(num)
            end
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
          foreach num in [1, 2, 3] do
            echo(num)
          end
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
})
