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
  InstantiationExpression,
  UnaryExpression,
  LogicalExpression,
  ClassLookupExpression,
} from '@/interpreter/expression'
import { ExecutionContext } from '@/interpreter/executor'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('parse', () => {
  test('without arguments', () => {
    const stmts = parse('log new Foo()')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const expStmt = stmts[0] as LogStatement

    expect(expStmt.expression).toBeInstanceOf(InstantiationExpression)
    const instantiationExpr = expStmt.expression as InstantiationExpression
    expect(instantiationExpr.className).toBeInstanceOf(ClassLookupExpression)
    expect(instantiationExpr.className.name.lexeme).toBe('Foo')
    expect(instantiationExpr.args).toBeEmpty()
  })

  test('with simple arguments', () => {
    const stmts = parse('log new Foo(1, "foo")')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const expStmt = stmts[0] as LogStatement

    expect(expStmt.expression).toBeInstanceOf(InstantiationExpression)
    const instantiationExpr = expStmt.expression as InstantiationExpression
    expect(instantiationExpr.className).toBeInstanceOf(ClassLookupExpression)
    expect(instantiationExpr.className.name.lexeme).toBe('Foo')
    expect((instantiationExpr.args[0] as LiteralExpression).value).toBe(1)
    expect((instantiationExpr.args[1] as LiteralExpression).value).toBe('foo')
  })

  test('with complex arguments', () => {
    const stmts = parse('log new Foo(true and false, !false)')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const expStmt = stmts[0] as LogStatement

    expect(expStmt.expression).toBeInstanceOf(InstantiationExpression)
    const instantiationExpr = expStmt.expression as InstantiationExpression
    expect(instantiationExpr.className).toBeInstanceOf(ClassLookupExpression)
    expect(instantiationExpr.className.name.lexeme).toBe('Foo')
    expect(instantiationExpr.args[0]).toBeInstanceOf(LogicalExpression)
    expect(instantiationExpr.args[1]).toBeInstanceOf(UnaryExpression)
  })
})

describe('execute', () => {
  test('no args', () => {
    const Person = new Jiki.Class('Person')
    Person.addConstructor(function (
      _: ExecutionContext,
      object: Jiki.Instance
    ) {
      object.setField('name', new Jiki.String('Jeremy'))
    })
    Person.addMethod(
      'name',
      '',
      'public',
      function (_: ExecutionContext, object: Jiki.Instance) {
        return object.getField('name')
      }
    )

    const context: EvaluationContext = { classes: [Person] }
    const { frames, error } = interpret(
      `set person to new Person()
      set name to person.name()`,
      context
    )

    // Last line
    const lastFrame = frames[frames.length - 1]
    expect(Jiki.unwrapJikiObject(lastFrame.variables)['name']).toBe('Jeremy')
  })

  test('args', () => {
    const Person = new Jiki.Class('Person')
    Person.addConstructor(function (
      _: ExecutionContext,
      object: Jiki.Instance,
      name: Jiki.JikiObject
    ) {
      object.setField('name', name)
    })
    Person.addMethod(
      'name',
      '',
      'public',

      function (_: ExecutionContext, object: Jiki.Instance) {
        return object.getField('name')
      }
    )

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
})
