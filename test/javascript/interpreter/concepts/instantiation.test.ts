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
    expect(instantiationExpr.className.lexeme).toBe('Foo')
    expect(instantiationExpr.args).toBeEmpty()
  })

  test('with simple arguments', () => {
    const stmts = parse('log new Foo(1, "foo")')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const expStmt = stmts[0] as LogStatement

    expect(expStmt.expression).toBeInstanceOf(InstantiationExpression)
    const instantiationExpr = expStmt.expression as InstantiationExpression
    expect(instantiationExpr.className.lexeme).toBe('Foo')
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
    expect(instantiationExpr.className.lexeme).toBe('Foo')
    expect(instantiationExpr.args[0]).toBeInstanceOf(LogicalExpression)
    expect(instantiationExpr.args[1]).toBeInstanceOf(UnaryExpression)
  })
})
