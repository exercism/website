import {
  Interpreter,
  interpret,
  evaluateFunction,
} from '@/interpreter/interpreter'
import type { ExecutionContext } from '@/interpreter/executor'
import { changeLanguage } from '@/interpreter/translator'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe.skip('template literals', () => {
  test('text only', () => {
    const { frames } = interpret('set x to `hello`')
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: 'hello' })
  })

  test('placeholder only', () => {
    const { frames } = interpret('set x to `${3*4}`')
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: '12' })
  })

  test('string', () => {
    const { frames } = interpret('set x to `hello ${"there"}`')
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: 'hello there' })
  })

  test('variable', () => {
    const { frames } = interpret(`
            set x to 1
            set y to \`x is \${x}\`
          `)
    expect(frames).toBeArrayOfSize(2)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: 1 })
    expect(frames[1].status).toBe('SUCCESS')
    expect(frames[1].variables).toMatchObject({ x: 1, y: 'x is 1' })
  })

  test('expression', () => {
    const { frames } = interpret('set x to `2 + 3 = ${2 + 3}`')
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: '2 + 3 = 5' })
  })

  test('complex', () => {
    const { frames } = interpret('set x to `${2} + ${"three"} = ${2 + 9 / 3}`')
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables).toMatchObject({ x: '2 + three = 5' })
  })

  describe('parsing', () => {
    test('empty', () => {
      const stmts = parse('``')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(TemplateLiteralExpression)
      const templateExpr = exprStmt.expression as TemplateLiteralExpression
      expect(templateExpr.parts).toBeEmpty()
    })

    test('no placeholders', () => {
      const stmts = parse('`hello there`')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(TemplateLiteralExpression)
      const templateExpr = exprStmt.expression as TemplateLiteralExpression
      expect(templateExpr.parts).toBeArrayOfSize(1)
      expect(templateExpr.parts[0]).toBeInstanceOf(TemplateTextExpression)
      const textExpr = templateExpr.parts[0] as TemplateTextExpression
      expect(textExpr.text.literal).toBe('hello there')
    })

    test('placeholders', () => {
      const stmts = parse('`sum of ${2} + ${1+3*5} = ${2+(1+4*5)}`')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ExpressionStatement)
      const exprStmt = stmts[0] as ExpressionStatement
      expect(exprStmt.expression).toBeInstanceOf(TemplateLiteralExpression)
      const templateExpr = exprStmt.expression as TemplateLiteralExpression
      expect(templateExpr.parts).toBeArrayOfSize(6)
      expect(templateExpr.parts[0]).toBeInstanceOf(TemplateTextExpression)
      expect(templateExpr.parts[1]).toBeInstanceOf(
        TemplatePlaceholderExpression
      )
      expect(templateExpr.parts[2]).toBeInstanceOf(TemplateTextExpression)
      expect(templateExpr.parts[3]).toBeInstanceOf(
        TemplatePlaceholderExpression
      )
      expect(templateExpr.parts[4]).toBeInstanceOf(TemplateTextExpression)
      expect(templateExpr.parts[5]).toBeInstanceOf(
        TemplatePlaceholderExpression
      )
      const part0Expr = templateExpr.parts[0] as TemplateTextExpression
      expect(part0Expr.text.lexeme).toBe('sum of ')
      const part1Expr = templateExpr.parts[1] as TemplatePlaceholderExpression
      expect(part1Expr.inner).toBeInstanceOf(LiteralExpression)
      const part2Expr = templateExpr.parts[2] as TemplateTextExpression
      expect(part2Expr.text.lexeme).toBe(' + ')
      const part3Expr = templateExpr.parts[3] as TemplatePlaceholderExpression
      expect(part3Expr.inner).toBeInstanceOf(BinaryExpression)
      const part4Expr = templateExpr.parts[4] as TemplateTextExpression
      expect(part4Expr.text.lexeme).toBe(' = ')
      const part5Expr = templateExpr.parts[5] as TemplatePlaceholderExpression
      expect(part5Expr.inner).toBeInstanceOf(BinaryExpression)
    })
  })
})
