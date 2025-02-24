import { parse } from '@/interpreter/parser'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import { LogStatement, MethodCallStatement } from '@/interpreter/statement'
import { last } from 'lodash'
import * as Jiki from '@/interpreter/jikiObjects'
import {
  MethodCallExpression,
  LiteralExpression,
  GetElementExpression,
  VariableLookupExpression,
} from '@/interpreter/expression'
import { ExecutionContext } from '@/interpreter/executor'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('parse', () => {
  describe('expression', () => {
    test('without arguments', () => {
      const stmts = parse('log foo.bar()')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const expStmt = stmts[0] as LogStatement
      expect(expStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = expStmt.expression as MethodCallExpression
      expect(callExpr.methodName.lexeme).toBe('bar')
      expect(callExpr.args).toBeEmpty()
    })

    test('single argument', () => {
      const stmts = parse('log foo.bar("left")')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = logStmt.expression as MethodCallExpression
      expect(callExpr.object).toBeInstanceOf(VariableLookupExpression)
      expect(callExpr.args).toBeArrayOfSize(1)
      expect(callExpr.methodName.lexeme).toBe('bar')
      expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
    })

    test('chained before', () => {
      const stmts = parse('log foo[0].bar()')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const expStmt = stmts[0] as LogStatement
      expect(expStmt.expression).toBeInstanceOf(MethodCallExpression)
      const callExpr = expStmt.expression as MethodCallExpression
      expect(callExpr.object).toBeInstanceOf(GetElementExpression)
      expect(callExpr.methodName.lexeme).toBe('bar')
      expect(callExpr.args).toBeEmpty()
    })
    test('chained after', () => {
      const stmts = parse('log foo.bar("left")[0]')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)

      const logStmt = stmts[0] as LogStatement

      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getStmt = logStmt.expression as GetElementExpression

      expect(getStmt.obj).toBeInstanceOf(MethodCallExpression)
      const callExpr = getStmt.obj as MethodCallExpression
      expect(callExpr.methodName.lexeme).toBe('bar')
      expect(callExpr.object).toBeInstanceOf(VariableLookupExpression)
      expect(callExpr.args).toBeArrayOfSize(1)
      expect(callExpr.args[0]).toBeInstanceOf(LiteralExpression)
      expect((callExpr.args[0] as LiteralExpression).value).toBe('left')

      expect(getStmt.field).toBeInstanceOf(LiteralExpression)
      const fieldExpr = getStmt.field as LiteralExpression
      expect(fieldExpr.value).toBe(0)
    })
    test('chained methods', () => {
      const stmts = parse('log foo.bar("left").rab("tusk")["3"]')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)

      const logStmt = stmts[0] as LogStatement

      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getStmt = logStmt.expression as GetElementExpression
      expect((getStmt.field as LiteralExpression).value).toBe('3')

      expect(getStmt.obj).toBeInstanceOf(MethodCallExpression)
      const callExpr = getStmt.obj as MethodCallExpression
      expect(callExpr.object).toBeInstanceOf(MethodCallExpression)
      expect(callExpr.methodName.lexeme).toBe('rab')
      expect((callExpr.args[0] as LiteralExpression).value).toBe('tusk')

      const innerCallExpr = callExpr.object as MethodCallExpression
      expect(innerCallExpr.methodName.lexeme).toBe('bar')
      expect(innerCallExpr.object).toBeInstanceOf(VariableLookupExpression)
      expect(
        (innerCallExpr.object as VariableLookupExpression).name.lexeme
      ).toBe('foo')
      expect(innerCallExpr.args).toBeArrayOfSize(1)
      expect((innerCallExpr.args[0] as LiteralExpression).value).toBe('left')
    })
  })
})

describe('execute', () => {
  test('no args', () => {
    const Person = new Jiki.Class('Person')
    Person.addConstructor(function (
      this: Jiki.Instance,
      _: ExecutionContext,
      name: Jiki.String
    ) {
      this.fields['name'] = name
    })
    Person.addMethod('name', function (this: any, _: ExecutionContext) {
      return this.fields['name']
    })

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(
      `set person to new Person("Jeremy")
      set name to person.name()`,
      context
    )

    // Last line
    const lastFrame = frames[frames.length - 1]
    expect(Jiki.unwrapJikiObject(lastFrame.variables)['name']).toBe('Jeremy')
  })

  test('with args', () => {
    const Person = new Jiki.Class('Person')
    Person.addConstructor(function (
      this: any,
      _: ExecutionContext,
      name: Jiki.String
    ) {
      this.name = name
    })
    Person.addMethod(
      'name_char',
      function (this: any, _: ExecutionContext, idx: Jiki.Number) {
        return new Jiki.String(this.name.value[idx.value - 1])
      }
    )

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(
      `set person to new Person("Jeremy")
      set name to person.name_char(3)`,
      context
    )

    // Last line
    const lastFrame = frames[frames.length - 1]
    expect(Jiki.unwrapJikiObject(lastFrame.variables)['name']).toBe('r')
  })

  describe('pass by value', () => {
    test.skip('lists', () => {
      const getObjectFunction = (_: any) => {
        const jikiObject = new Jiki.Number(5)
        jikiObject.methods.set(
          // TODO: We've removed methods from numbers
          'increment_all',
          new Jiki.Method(
            'increment_all',
            1,
            (_: EvaluationContext, ...args) => {
              args[0].value += 1
              return new Jiki.Number(3)
            }
          )
        )
        return jikiObject
      }
      const context: EvaluationContext = {
        externalFunctions: [
          {
            name: 'get_object',
            func: getObjectFunction,
            description: '',
          },
        ],
      }
      const { frames, error } = interpret(
        `
      set original to [1, 2, 3]
      get_object().increment_all(original)
      log original
    `,
        context
      )

      // Last line
      const lastFrame = frames[frames.length - 1]
      expect(Jiki.unwrapJikiObject(lastFrame.variables)['original']).toEqual([
        1, 2, 3,
      ])
    })
  })
})
