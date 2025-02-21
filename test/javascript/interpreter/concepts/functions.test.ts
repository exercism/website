import { parse } from '@/interpreter/parser'
import { interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import { FunctionStatement, ReturnStatement } from '@/interpreter/statement'
import { unwrapJikiObject } from '@/interpreter/jikiObjects'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('parse', () => {
  test('without parameters', () => {
    const stmts = parse(`
      function move do
        return 1
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionStatement)
    const functionStmt = stmts[0] as FunctionStatement
    expect(functionStmt.name.lexeme).toBe('move')
    expect(functionStmt.parameters).toBeEmpty()
    expect(functionStmt.body).toBeArrayOfSize(1)
    expect(functionStmt.body[0]).toBeInstanceOf(ReturnStatement)
  })

  test('with parameters', () => {
    const stmts = parse(`
      function move with x, y do
        return x + y
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(FunctionStatement)
    const functionStmt = stmts[0] as FunctionStatement
    expect(functionStmt.name.lexeme).toBe('move')
    expect(functionStmt.parameters).toBeArrayOfSize(2)
    expect(functionStmt.parameters[0].name.lexeme).toBe('x')
    expect(functionStmt.parameters[1].name.lexeme).toBe('y')
    expect(functionStmt.body).toBeArrayOfSize(1)
    expect(functionStmt.body[0]).toBeInstanceOf(ReturnStatement)
  })
})
describe('interpret', () => {
  describe('creating function', () => {
    test('without parameters', () => {
      const { frames } = interpret(`
            function move {
              return 1
            }
          `)
      expect(frames).toBeEmpty()
    })
    test('with parameters', () => {
      const { frames } = interpret(`
          function move with x do
            return 1 + x
          end
        `)
      expect(frames).toBeEmpty()
    })
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
      expect(unwrapJikiObject(frames[0].variables)).toBeEmpty()
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({ x: 1 })
    })
  })

  test('with params', () => {
    const { frames } = interpret(`
        function move with x do
          return 1 + x
        end
        set x to move(2)
      `)
    expect(frames).toBeArrayOfSize(2)
    expect(frames[0].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[0].variables)).toMatchObject({ x: 2 })
    expect(frames[1].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[1].variables)).toMatchObject({ x: 3 })
  })

  test('return pops loop and function', () => {
    const { frames } = interpret(`
        function move do
          set x to 0
          for each i in [1,2,3] do
            return x + 1
          end
        end
        set res to move()
      `)
    expect(frames).toBeArrayOfSize(4)
    expect(frames[3].status).toBe('SUCCESS')
    expect(unwrapJikiObject(frames[3].variables)).toMatchObject({ res: 1 })
  })
})
