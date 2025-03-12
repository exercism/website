import { parse } from '@/interpreter/parser'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import {
  ClassStatement,
  ConstructorStatement,
  LogStatement,
  MethodCallStatement,
  MethodStatement,
  PropertyStatement,
} from '@/interpreter/statement'
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
  test('class statement', () => {
    const stmts = parse(`
      class Foobar do
      end
    `)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ClassStatement)
    const classStatement = stmts[0] as ClassStatement
    expect(classStatement.name.lexeme).toBe('Foobar')
    expect(classStatement.body).toBeEmpty()
  })
  describe('constructor statement', () => {
    test('naked', () => {
      const stmts = parse(`
        class Foobar do
          constructor do
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        ConstructorStatement
      )
      const constructorStatement = (stmts[0] as ClassStatement)
        .body[0] as ConstructorStatement
      expect(constructorStatement.parameters).toBeEmpty()
      expect(constructorStatement.body).toBeEmpty()
    })
    test('args', () => {
      const stmts = parse(`
        class Foobar do
          constructor with arg1, arg2 do
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        ConstructorStatement
      )
      const constructorStatement = (stmts[0] as ClassStatement)
        .body[0] as ConstructorStatement
      expect(
        constructorStatement.parameters.map((p) => p.name.lexeme)
      ).toIncludeSameMembers(['arg1', 'arg2'])
      expect(constructorStatement.body).toBeEmpty()
    })
  })
  describe('method statement', () => {
    test('public naked', () => {
      const stmts = parse(`
        class Foobar do
          public method foobar do
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        MethodStatement
      )
      const methodStatement = (stmts[0] as ClassStatement)
        .body[0] as MethodStatement
      expect(methodStatement.accessModifier.lexeme).toBe('public')
      expect(methodStatement.name.lexeme).toBe('foobar')
      expect(methodStatement.parameters).toBeEmpty()
      expect(methodStatement.body).toBeEmpty()
    })
    test('public args', () => {
      const stmts = parse(`
        class Foobar do
          public method foobar with arg1, arg2 do
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        MethodStatement
      )
      const methodStatement = (stmts[0] as ClassStatement)
        .body[0] as MethodStatement
      expect(methodStatement.accessModifier.lexeme).toBe('public')
      expect(methodStatement.name.lexeme).toBe('foobar')
      expect(
        methodStatement.parameters.map((p) => p.name.lexeme)
      ).toIncludeSameMembers(['arg1', 'arg2'])
      expect(methodStatement.body).toBeEmpty()
    })
    test('private naked', () => {
      const stmts = parse(`
        class Foobar do
          private method foobar do
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        MethodStatement
      )
      const methodStatement = (stmts[0] as ClassStatement)
        .body[0] as MethodStatement
      expect(methodStatement.accessModifier.lexeme).toBe('private')
      expect(methodStatement.name.lexeme).toBe('foobar')
      expect(methodStatement.parameters).toBeEmpty()
      expect(methodStatement.body).toBeEmpty()
    })
    test('private with args', () => {
      const stmts = parse(`
        class Foobar do
          private method foobar with arg1, arg2 do
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        MethodStatement
      )
      const methodStatement = (stmts[0] as ClassStatement)
        .body[0] as MethodStatement
      expect(methodStatement.accessModifier.lexeme).toBe('private')
      expect(methodStatement.name.lexeme).toBe('foobar')
      expect(
        methodStatement.parameters.map((p) => p.name.lexeme)
      ).toIncludeSameMembers(['arg1', 'arg2'])
      expect(methodStatement.body).toBeEmpty()
    })
  })
  describe('property statement', () => {
    test('public', () => {
      const stmts = parse(`
        class Foobar do
          public property foobar
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        PropertyStatement
      )
      const propertyStatement = (stmts[0] as ClassStatement)
        .body[0] as PropertyStatement
      expect(propertyStatement.accessModifier.lexeme).toBe('public')
      expect(propertyStatement.name.lexeme).toBe('foobar')
    })
    test('private', () => {
      const stmts = parse(`
        class Foobar do
          private property foobar
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        PropertyStatement
      )
      const propertyStatement = (stmts[0] as ClassStatement)
        .body[0] as PropertyStatement
      expect(propertyStatement.accessModifier.lexeme).toBe('private')
      expect(propertyStatement.name.lexeme).toBe('foobar')
    })
  })
})
