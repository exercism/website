import { parse } from '@/interpreter/parser'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangeElementStatement,
  LogStatement,
  MethodCallStatement,
} from '@/interpreter/statement'
import { last } from 'lodash'
import * as Jiki from '@/interpreter/jikiObjects'
import {
  MethodCallExpression,
  LiteralExpression,
  GetElementExpression,
  VariableLookupExpression,
  AccessorExpression,
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
    const stmts = parse('log foo.bar')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const expStmt = stmts[0] as LogStatement
    expect(expStmt.expression).toBeInstanceOf(AccessorExpression)
    const accessorExpr = expStmt.expression as AccessorExpression
    expect(accessorExpr.property.lexeme).toBe('bar')
  })

  test('chained before', () => {
    const stmts = parse('log foo[0].bar')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)
    const expStmt = stmts[0] as LogStatement
    expect(expStmt.expression).toBeInstanceOf(AccessorExpression)
    const accessorExpr = expStmt.expression as AccessorExpression
    expect(accessorExpr.object).toBeInstanceOf(GetElementExpression)
    expect(accessorExpr.property.lexeme).toBe('bar')
  })
  test('chained after', () => {
    const stmts = parse('log foo.bar[0]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)

    const logStmt = stmts[0] as LogStatement

    expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
    const getStmt = logStmt.expression as GetElementExpression

    expect(getStmt.obj).toBeInstanceOf(AccessorExpression)
    const accessorExpr = getStmt.obj as AccessorExpression
    expect(accessorExpr.property.lexeme).toBe('bar')
    expect(accessorExpr.object).toBeInstanceOf(VariableLookupExpression)

    expect(getStmt.field).toBeInstanceOf(LiteralExpression)
    const fieldExpr = getStmt.field as LiteralExpression
    expect(fieldExpr.value).toBe(0)
  })
  test('chained methods', () => {
    const stmts = parse('log foo.bar.rab["3"]')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(LogStatement)

    const logStmt = stmts[0] as LogStatement

    expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
    const getStmt = logStmt.expression as GetElementExpression
    expect((getStmt.field as LiteralExpression).value).toBe('3')

    expect(getStmt.obj).toBeInstanceOf(AccessorExpression)
    const accessorExpr = getStmt.obj as AccessorExpression
    expect(accessorExpr.object).toBeInstanceOf(AccessorExpression)
    expect(accessorExpr.property.lexeme).toBe('rab')

    const innerAccessorExpr = accessorExpr.object as AccessorExpression
    expect(innerAccessorExpr.property.lexeme).toBe('bar')
    expect(innerAccessorExpr.object).toBeInstanceOf(VariableLookupExpression)
    expect(
      (innerAccessorExpr.object as VariableLookupExpression).name.lexeme
    ).toBe('foo')
  })
  test('chained properties', () => {
    const stmts = parse('change foo.bar.rab["3"] to true')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ChangeElementStatement)

    const changeStmt = stmts[0] as ChangeElementStatement
    expect(changeStmt.value).toBeInstanceOf(LiteralExpression)
    expect((changeStmt.value as LiteralExpression).value).toBe(true)

    expect(changeStmt.object).toBeInstanceOf(AccessorExpression)
    const getStmt = changeStmt.object as AccessorExpression
    expect(getStmt.property.lexeme).toBe('rab')
    expect((changeStmt.field as LiteralExpression).value).toBe('3')

    expect(getStmt.object).toBeInstanceOf(AccessorExpression)
    const accessorExpr = getStmt.object as AccessorExpression
    expect(accessorExpr.object).toBeInstanceOf(VariableLookupExpression)
    expect(accessorExpr.property.lexeme).toBe('bar')

    expect((accessorExpr.object as VariableLookupExpression).name.lexeme).toBe(
      'foo'
    )
  })
})

test('execute', () => {
  const Person = new Jiki.Class('Person')
  Person.addConstructor(function (
    _: ExecutionContext,
    object: Jiki.Instance,
    name: Jiki.JikiObject
  ) {
    object.setField('name', name)
  })
  Person.addProperty('name')
  Person.addGetter('name')

  const context: EvaluationContext = { classes: [Person] }
  const { frames, error } = interpret(
    `set person to new Person("Jeremy")
    set name to person.name`,
    context
  )

  // Last line
  const lastFrame = frames[frames.length - 1]
  expect(Jiki.unwrapJikiObject(lastFrame.variables)['name']).toBe('Jeremy')
})
