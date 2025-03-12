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
      expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
        'div',
      ])
      expect(selectorStmt.body).toBeEmpty()
    })
    test('mixed', () => {
      const stmts = parse('div, span {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
        'div',
        'span',
      ])
      expect(selectorStmt.body).toBeEmpty()
    })
  })
  describe('class', () => {
    test('single', () => {
      const stmts = parse('.btn {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
        '.btn',
      ])
      expect(selectorStmt.body).toBeEmpty()
    })
    test('mixed', () => {
      const stmts = parse('.btn, .heading {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
        '.btn',
        '.heading',
      ])
      expect(selectorStmt.body).toBeEmpty()
    })
  })
  describe('id', () => {
    test('single', () => {
      const stmts = parse('#btn {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
        '#btn',
      ])
      expect(selectorStmt.body).toBeEmpty()
    })
    test('mixed', () => {
      const stmts = parse('#btn, .heading {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SelectorStatement)
      const selectorStmt = stmts[0] as SelectorStatement
      expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
        '#btn',
        '#heading',
      ])
      expect(selectorStmt.body).toBeEmpty()
    })
  })
  test('chained', () => {
    const stmts = parse('.btn .heading {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
      '.btn',
      '.heading',
    ])
    expect(selectorStmt.body).toBeEmpty()
  })
  test('descendents', () => {
    const stmts = parse('.btn > .heading {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
      '.btn',
      '.heading',
    ])
    expect(selectorStmt.body).toBeEmpty()
  })
  test('next to', () => {
    const stmts = parse('.btn + .heading {}')
    expect(stmts).toBeArrayOfSize(1)
    expect(stmts[0]).toBeInstanceOf(SelectorStatement)
    const selectorStmt = stmts[0] as SelectorStatement
    expect(selectorStmt.selectors.map((s) => s.lexeme)).toIncludeSameMembers([
      '.btn',
      '.heading',
    ])
    expect(selectorStmt.body).toBeEmpty()
  })
})
