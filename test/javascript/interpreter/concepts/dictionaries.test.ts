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

describe.skip('dictionary', () => {
  describe('parse', () => {
    test('empty', () => {
      const stmts = parse('set empty to {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      const varStmt = stmts[0] as SetVariableStatement
      expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
      const mapExpr = varStmt.initializer as DictionaryExpression
      expect(mapExpr.elements).toBeEmpty()
    })

    test('single element', () => {
      const stmts = parse('set movie to {"title": "Jurassic Park"}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      const varStmt = stmts[0] as SetVariableStatement
      expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
      const mapExpr = varStmt.initializer as DictionaryExpression
      expect(mapExpr.elements.size).toBe(1)
      expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
      expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
        'Jurassic Park'
      )
    })

    test('multiple elements', () => {
      const stmts = parse(
        'set movie to {"title": "Jurassic Park", "year": 1993}'
      )
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      const varStmt = stmts[0] as SetVariableStatement
      expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
      const mapExpr = varStmt.initializer as DictionaryExpression
      expect(mapExpr.elements.size).toBe(2)
      expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
      expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
        'Jurassic Park'
      )
      expect(mapExpr.elements.get('year')).toBeInstanceOf(LiteralExpression)
      expect((mapExpr.elements.get('year') as LiteralExpression).value).toBe(
        1993
      )
    })

    test('nested', () => {
      const stmts = parse(
        'set movie to {"title": "Jurassic Park", "director": { "name": "Steven Spielberg" } }'
      )
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      const varStmt = stmts[0] as SetVariableStatement
      expect(varStmt.initializer).toBeInstanceOf(DictionaryExpression)
      const mapExpr = varStmt.initializer as DictionaryExpression
      expect(mapExpr.elements.size).toBe(2)
      expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
      expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
        'Jurassic Park'
      )
      expect(mapExpr.elements.get('director')).toBeInstanceOf(
        DictionaryExpression
      )
      const nestedMapExpr = mapExpr.elements.get(
        'director'
      ) as DictionaryExpression
      expect(nestedMapExpr.elements.size).toBe(1)
      expect(nestedMapExpr.elements.get('name')).toBeInstanceOf(
        LiteralExpression
      )
      expect(
        (nestedMapExpr.elements.get('name') as LiteralExpression).value
      ).toBe('Steven Spielberg')
    })
  })

  describe('execute', () => {
    describe('set', () => {
      test('single field', () => {
        const { frames } = interpret(`
            set movie to {"title": "The Matrix"}
            set movie["title"] to "Gladiator"
          `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({
          movie: { title: 'The Matrix' },
        })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({
          movie: { title: 'Gladiator' },
        })
      })

      test('chained', () => {
        const { frames } = interpret(`
            set movie to {"director": {"name": "Peter Jackson"}}
            set movie["director"]["name"] to "James Cameron"
          `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({
          movie: { director: { name: 'Peter Jackson' } },
        })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({
          movie: { director: { name: 'James Cameron' } },
        })
      })
    })

    describe('get', () => {
      test('single field', () => {
        const { frames } = interpret(`
                  set movie to {"title": "The Matrix"}
                  set title to movie["title"]
                `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({
          movie: { title: 'The Matrix' },
        })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({
          movie: { title: 'The Matrix' },
          title: 'The Matrix',
        })
      })

      test('chained', () => {
        const { frames } = interpret(`
                  set movie to {"director": {"name": "Peter Jackson"}}
                  set name to movie["director"]["name"]
                `)
        expect(frames).toBeArrayOfSize(2)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables).toMatchObject({
          movie: { director: { name: 'Peter Jackson' } },
        })
        expect(frames[1].status).toBe('SUCCESS')
        expect(frames[1].variables).toMatchObject({
          movie: { director: { name: 'Peter Jackson' } },
          name: 'Peter Jackson',
        })
      })
    })

    describe('parsing', () => {
      test('single field', () => {
        const stmts = parse(`
                    set movie to {"title": "The Matrix"}
                    set movie["title"] to "Gladiator"
                  `)
        expect(stmts).toBeArrayOfSize(2)
        expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
        expect(stmts[1]).toBeInstanceOf(ExpressionStatement)
        const exprStmt = stmts[1] as ExpressionStatement
        expect(exprStmt.expression).toBeInstanceOf(SetExpression)
        const setExpr = exprStmt.expression as SetExpression
        expect(setExpr.field.literal).toBe('title')
        expect(setExpr.obj).toBeInstanceOf(VariableExpression)
        expect((setExpr.obj as VariableExpression).name.lexeme).toBe('movie')
      })

      test('chained', () => {
        const stmts = parse(`
                    set movie to {"director": {"name": "Peter Jackson"}}
                    set movie["director"]["name"] to "James Cameron"
                  `)
        expect(stmts).toBeArrayOfSize(2)
        expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
        expect(stmts[1]).toBeInstanceOf(ExpressionStatement)
        const exprStmt = stmts[1] as ExpressionStatement
        expect(exprStmt.expression).toBeInstanceOf(SetExpression)
        const setExpr = exprStmt.expression as SetExpression
        expect(setExpr.value).toBeInstanceOf(LiteralExpression)
        expect((setExpr.value as LiteralExpression).value).toBe('James Cameron')
        expect(setExpr.field.literal).toBe('name')
        expect(setExpr.obj).toBeInstanceOf(GetExpression)
        const getExpr = setExpr.obj as GetExpression
        expect(getExpr.obj).toBeInstanceOf(VariableExpression)
        expect((getExpr.obj as VariableExpression).name.lexeme).toBe('movie')
        expect(getExpr.field.literal).toBe('director')
      })
    })
  })
})
