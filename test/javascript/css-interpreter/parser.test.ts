import { ValueExpression } from '@/css-interpreter/expression'
import {
  SelectorStatement,
  PropertyStatement,
} from '@/css-interpreter/statement'
import { parse } from '@/css-interpreter/parser'

describe('selectors', () => {
  describe('tag', () => {
    test('single', () => {
      const stmts = parse('div {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers(
        ['div']
      )
      expect(selectorStmt.body).toBeEmpty()
    })
    test('mixed', () => {
      const stmts = parse('div, span {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers(
        ['div', 'span']
      )
      expect(selectorStmt.body).toBeEmpty()
    })
  })
  describe('class', () => {
    test('single', () => {
      const stmts = parse('.btn {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers(
        ['.btn']
      )
      expect(selectorStmt.body).toBeEmpty()
    })
    test('mixed', () => {
      const stmts = parse('.btn, .heading {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers(
        ['.btn', '.heading']
      )
      expect(selectorStmt.body).toBeEmpty()
    })
  })
  describe('id', () => {
    test('single', () => {
      const stmts = parse('#btn {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers(
        ['#btn']
      )
      expect(selectorStmt.body).toBeEmpty()
    })
    test('mixed', () => {
      const stmts = parse('#btn, #heading {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers(
        ['#btn', '#heading']
      )
      expect(selectorStmt.body).toBeEmpty()
    })
  })
  test('chained', () => {
    const stmts = parse('.btn .heading {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers([
      '.btn .heading',
    ])
    expect(selectorStmt.body).toBeEmpty()
  })
  test('descendents', () => {
    const stmts = parse('.btn > .heading {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers([
      '.btn > .heading',
    ])
    expect(selectorStmt.body).toBeEmpty()
  })
  test('next to', () => {
    const stmts = parse('.btn + .heading {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.selectors.map((s) => s.literal)).toIncludeSameMembers([
      '.btn + .heading',
    ])
    expect(selectorStmt.body).toBeEmpty()
  })
})

describe('properties', () => {
  describe('single', () => {
    test('with semicolon', () => {
      const stmts = parse(`div {
        color: red;
      }`)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.body).toBeArrayOfSize(1)

      const propertyStmt = selectorStmt.body[0] as PropertyStatement
      expect(propertyStmt.property.lexeme).toBe('color')
      expect(propertyStmt.value).toBeInstanceOf(ValueExpression)
      expect(propertyStmt.value.value).toBe('red')
    })
    test('without semicolon', () => {
      const stmts = parse(`div {
        color: red
      }`)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.body).toBeArrayOfSize(1)

      const propertyStmt = selectorStmt.body[0] as PropertyStatement
      expect(propertyStmt.property.lexeme).toBe('color')
      expect(propertyStmt.value).toBeInstanceOf(ValueExpression)
      expect(propertyStmt.value.value).toBe('red')
    })
  })
  describe('multiple', () => {
    const stmts = parse(`div {
      color: red;
      background: blue
    }`)
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.body).toBeArrayOfSize(2)

    const propertyStmt1 = selectorStmt.body[0] as PropertyStatement
    expect(propertyStmt1.property.lexeme).toBe('color')
    expect(propertyStmt1.value).toBeInstanceOf(ValueExpression)
    expect(propertyStmt1.value.value).toBe('red')

    const propertyStmt2 = selectorStmt.body[1] as PropertyStatement
    expect(propertyStmt2.property.lexeme).toBe('background')
    expect(propertyStmt2.value).toBeInstanceOf(ValueExpression)
    expect(propertyStmt2.value.value).toBe('blue')
  })
})
