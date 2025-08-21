import { interpret } from '@/interpreter/interpreter'
import { parse } from '@/interpreter/parser'
import { changeLanguage } from '@/interpreter/translator'
import {
  ContinueStatement,
  ForeachStatement,
  SetVariableStatement,
} from '@/interpreter/statement'
import { Location } from '@/interpreter/location'
import {
  FunctionCallExpression,
  ListExpression,
  LiteralExpression,
} from '@/interpreter/expression'
import { RuntimeError } from '@/interpreter/error'
import { Primitive } from '@/interpreter/jikiObjects'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

const generateEchosContext = (echos) => {
  return {
    externalFunctions: [
      {
        name: 'echo',
        func: (_: any, n: Primitive) => {
          echos.push(n.value.toString())
        },
        description: '',
      },
    ],
  }
}

describe('execute', () => {
  test('multiple times', () => {
    const echos: string[] = []
    const { frames } = interpret(
      `
      repeat 3 times do
        echo("a")
      end
    `,
      generateEchosContext(echos)
    )
    expect(frames).toBeArrayOfSize(6)
    expect(frames[frames.length - 1].status).toBe('SUCCESS')
    expect(echos).toEqual(['a', 'a', 'a'])
  })

  test('indexed by', () => {
    const echos: string[] = []
    const { frames } = interpret(
      `
      repeat 3 times indexed by idx do
        echo(idx)
      end
    `,
      generateEchosContext(echos)
    )
    expect(frames).toBeArrayOfSize(6)
    expect(frames[frames.length - 1].status).toBe('SUCCESS')
    expect(echos).toEqual(['1', '2', '3'])
  })

  test('continue', () => {
    const echos: string[] = []

    const { frames } = interpret(
      `
      repeat 5 times indexed by idx do
        if idx == 3 or idx == 4 do
          continue 
        end
        echo(idx)
      end
    `,
      generateEchosContext(echos)
    )
    expect(frames).toBeArrayOfSize(15)
    expect(frames[frames.length - 1].status).toBe('SUCCESS')
    expect(echos).toEqual(['1', '2', '5'])
  })
  test('next', () => {
    const echos: string[] = []

    const { frames } = interpret(
      `
      repeat 5 times indexed by idx do
        if idx == 3 or idx == 4 do
          next 
        end
        echo(idx)
      end
    `,
      generateEchosContext(echos)
    )
    expect(frames).toBeArrayOfSize(15)
    expect(frames[frames.length - 1].status).toBe('SUCCESS')
    expect(echos).toEqual(['1', '2', '5'])
  })

  test('break', () => {
    const echos: string[] = []

    const { frames } = interpret(
      `
      repeat 5 times indexed by idx do
        if idx == 3 do
          break 
        end
        echo(idx)
      end
    `,
      generateEchosContext(echos)
    )
    expect(frames).toBeArrayOfSize(9)
    expect(frames[frames.length - 1].status).toBe('SUCCESS')
    expect(echos).toEqual(['1', '2'])
  })

  test('counter does not leak', () => {
    const { frames } = interpret(
      `
      repeat 1 times indexed by idx do
      end
      log idx
    `,
      {}
    )
    const lastFrame = frames[frames.length - 1]
    expect(lastFrame.status).toBe('ERROR')
    expect(lastFrame.error).toBeInstanceOf(RuntimeError)
    expect(lastFrame.error?.message).toMatch(/VariableNotDeclared: name: idx/)
  })
  test.skip('counter does not leak with break', () => {
    const { frames } = interpret(
      `
      repeat 1 times indexed by idx do
      end
      log idx
    `,
      {}
    )
    const lastFrame = frames[frames.length - 1]
    expect(lastFrame.status).toBe('ERROR')
    expect(lastFrame.error).toBeInstanceOf(RuntimeError)
    expect(lastFrame.error?.message).toMatch(/VariableNotDeclared: name: idx/)
  })
})
