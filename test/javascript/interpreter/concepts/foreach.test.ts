import { interpret } from '@/interpreter/interpreter'
import { parse } from '@/interpreter/parser'
import { changeLanguage } from '@/interpreter/translator'
import { ForeachStatement, SetVariableStatement } from '@/interpreter/statement'
import {
  CallExpression,
  ListExpression,
  LiteralExpression,
} from '@/interpreter/expression'
import { RuntimeError } from '@/interpreter/error'

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
        func: (_: any, n: any) => {
          echos.push(n.toString())
        },
        description: '',
      },
    ],
  }
}

describe('for each', () => {
  describe('parse', () => {
    test('with single statement in body', () => {
      const stmts = parse(`
      for each elem in [] do
        set x to elem + 1
      end
    `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ForeachStatement)
      const foreachStmt = stmts[0] as ForeachStatement
      expect(foreachStmt.elementName.lexeme).toBe('elem')
      expect(foreachStmt.iterable).toBeInstanceOf(ListExpression)
      expect(foreachStmt.body).toBeArrayOfSize(1)
      expect(foreachStmt.body[0]).toBeInstanceOf(SetVariableStatement)
    })

    test('with multiple statements in body', () => {
      const stmts = parse(`
      for each elem in [] do
        set x to elem + 1
        set y to elem - 1
      end
    `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ForeachStatement)
      const foreachStmt = stmts[0] as ForeachStatement
      expect(foreachStmt.elementName.lexeme).toBe('elem')
      expect(foreachStmt.iterable).toBeInstanceOf(ListExpression)
      expect(foreachStmt.body).toBeArrayOfSize(2)
      expect(foreachStmt.body[0]).toBeInstanceOf(SetVariableStatement)
      expect(foreachStmt.body[1]).toBeInstanceOf(SetVariableStatement)
    })

    test('with strings', () => {
      const stmts = parse(`
      for each elem in "foo" do
      end
    `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ForeachStatement)
      const foreachStmt = stmts[0] as ForeachStatement
      expect(foreachStmt.elementName.lexeme).toBe('elem')
      expect(foreachStmt.iterable).toBeInstanceOf(LiteralExpression)
    })
    test('with functions', () => {
      const stmts = parse(`
      for each elem in foo() do
      end
    `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ForeachStatement)
      const foreachStmt = stmts[0] as ForeachStatement
      expect(foreachStmt.elementName.lexeme).toBe('elem')
      expect(foreachStmt.iterable).toBeInstanceOf(CallExpression)
    })
  })
  describe('execute', () => {
    describe('lists', () => {
      test('empty iterable', () => {
        const echos: string[] = []
        const { frames } = interpret(
          `
          for each num in [] do
            echo(num)
          end
          `,
          generateEchosContext(echos)
        )
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toBeEmpty()
        expect(echos).toBeEmpty()
      })
      test('once', () => {
        const echos: string[] = []
        const { frames } = interpret(
          `
          for each num in [1] do
            echo(num)
          end
        `,
          generateEchosContext(echos)
        )
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ num: 1 })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({ num: 1 })
        expect(echos).toEqual(['1'])
      })
      test('multiple times', () => {
        const echos: string[] = []
        const { frames } = interpret(
          `
          for each num in [1, 2, 3] do
            echo(num)
          end
        `,
          generateEchosContext(echos)
        )
        expect(frames).toBeArrayOfSize(6)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ num: 1 })
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
    describe('strings', () => {
      test('empty iterable', () => {
        const echos: string[] = []
        const { frames } = interpret(
          `
            for each num in "" do
              echo(num)
            end
            `,
          generateEchosContext(echos)
        )
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toBeEmpty()
        expect(echos).toBeEmpty()
      })
      test('once', () => {
        const echos: string[] = []
        const { frames } = interpret(
          `
          for each num in "a" do
            echo(num)
          end
        `,
          generateEchosContext(echos)
        )
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ num: 'a' })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({ num: 'a' })
        expect(echos).toEqual(['a'])
      })
      test('multiple times', () => {
        const echos: string[] = []

        const { frames } = interpret(
          `
          for each num in "abc" do
            echo(num)
          end
        `,
          generateEchosContext(echos)
        )
        expect(frames).toBeArrayOfSize(6)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({ num: 'a' })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({ num: 'a' })
        expect(frames[2].status).toBe('SUCCESS')
        expect(frames[3].status).toBe('SUCCESS')
        expect(frames[3].variables).toMatchObject({ num: 'b' })
        expect(frames[4].status).toBe('SUCCESS')
        expect(frames[5].status).toBe('SUCCESS')
        expect(frames[5].variables).toMatchObject({ num: 'c' })
        expect(echos).toEqual(['a', 'b', 'c'])
      })
    })
    test('sets variables in top scope', () => {
      const { frames } = interpret(
        `
        for each num in [1] do
          set foo to "bar"
        end
        log foo
      `,
        {}
      )
      const lastFrame = frames[frames.length - 1]
      expect(lastFrame.status).toBe('SUCCESS')
      expect(lastFrame.variables).toMatchObject({ foo: 'bar' })
    })
    test('iterator does not leak', () => {
      const { frames } = interpret(
        `
        for each num in [1] do
        end
        log num
      `,
        {}
      )
      const lastFrame = frames[frames.length - 1]
      expect(lastFrame.status).toBe('ERROR')
      expect(lastFrame.error).toBeInstanceOf(RuntimeError)
      expect(lastFrame.error?.message).toMatch(/VariableNotDeclared: name: num/)
    })
  })
})
