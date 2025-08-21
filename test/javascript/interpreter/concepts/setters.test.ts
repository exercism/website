import { parse } from '@/interpreter/parser'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangeElementStatement,
  ChangePropertyStatement,
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
  test('basic', () => {
    const stmts = parse('change foo.bar to true')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ChangePropertyStatement)
    const changeStmt = stmts[0] as ChangePropertyStatement
    expect(changeStmt.object).toBeInstanceOf(VariableLookupExpression)
    expect(changeStmt.object.name.lexeme).toBe('foo')
    expect(changeStmt.property.lexeme).toBe('bar')
  })

  test('chained before', () => {
    const stmts = parse('change foo[0].bar to true')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(ChangePropertyStatement)
    const changeStmt = stmts[0] as ChangePropertyStatement
    expect(changeStmt.object).toBeInstanceOf(GetElementExpression)
    expect(changeStmt.property.lexeme).toBe('bar')
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
  Person.addGetter('name', 'public')
  Person.addSetter('name', 'public')

  const context: EvaluationContext = { classes: [Person] }
  const { frames, error } = interpret(
    `set person to new Person("Jeremy")
      change person.name to "Nicole"
      set name to person.name`,
    context
  )

  // Last line
  const lastFrame = frames[frames.length - 1]
  expect(Jiki.unwrapJikiObject(lastFrame.variables)['name']).toBe('Nicole')
})
