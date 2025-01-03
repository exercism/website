import { interpret } from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'

describe('execution context', () => {
  describe('externalFunctions', () => {
    test('function', () => {
      const echos: string[] = []
      const context = {
        externalFunctions: {
          echo: (_: ExecutionContext, value: any) => {
            echos.push(value.toString())
          },
        },
      }

      interpret('echo(1)', context)
      expect(echos).toBeArrayOfSize(1)
      expect(echos[0]).toBe('1')
    })
  })
})
