import {
  Interpreter,
  interpret,
  evaluateFunction,
} from '@/interpreter/interpreter'
import { parse } from '@/interpreter/parser'
import type { ExecutionContext } from '@/interpreter/executor'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangeVariableStatement,
  SetVariableStatement,
} from '@/interpreter/statement'
import {
  GetExpression,
  VariableLookupExpression,
} from '@/interpreter/expression'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('foreach', () => {
  describe.skip('execute', () => {
    test.skip('empty iterable', () => {
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
    test.skip('multiple times', () => {
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
