import { interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangeElementStatement,
  LogStatement,
  SetVariableStatement,
} from '@/interpreter/statement'
import {
  GetElementExpression,
  DictionaryExpression,
  LiteralExpression,
  SetElementExpression,
  BinaryExpression,
  VariableLookupExpression,
  FunctionCallExpression,
  LogicalExpression,
} from '@/interpreter/expression'
import { parse } from '@/interpreter/parser'
import { Dictionary, String, unwrapJikiObject } from '@/interpreter/jikiObjects'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

describe('parse', () => {
  describe('init', () => {
    test('empty', () => {
      const stmts = parse('log {}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(DictionaryExpression)
      const mapExpr = logStmt.expression as DictionaryExpression
      expect(mapExpr.elements).toBeEmpty()
    })

    test('single element', () => {
      const stmts = parse('log {"title": "Jurassic Park"}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(DictionaryExpression)
      const mapExpr = logStmt.expression as DictionaryExpression
      expect(mapExpr.elements.size).toBe(1)
      expect(mapExpr.elements.get('title')).toBeInstanceOf(LiteralExpression)
      expect((mapExpr.elements.get('title') as LiteralExpression).value).toBe(
        'Jurassic Park'
      )
    })

    test('multiple elements', () => {
      const stmts = parse('log {"title": "Jurassic Park", "year": 1993}')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(DictionaryExpression)
      const mapExpr = logStmt.expression as DictionaryExpression
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

    test('multiple elements over 2 lines', () => {
      const stmts = parse(`log {
                                "title": "Jurassic Park", 
                                "year": 1993
                               }`)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(DictionaryExpression)
      const mapExpr = logStmt.expression as DictionaryExpression
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

    test('or with function call as a value', () => {
      const stmts = parse('log {"bar": foo() or true }')
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(DictionaryExpression)
      const mapExpr = logStmt.expression as DictionaryExpression
      expect(mapExpr.elements.get('bar')).toBeInstanceOf(LogicalExpression)
      const orExpr = mapExpr.elements.get('bar') as LogicalExpression
      expect(orExpr.left).toBeInstanceOf(FunctionCallExpression)
      expect(orExpr.right).toBeInstanceOf(LiteralExpression)
      const callExpr = orExpr.left as FunctionCallExpression
      expect(callExpr.callee.name.lexeme).toBe('foo')
    })

    test('nested', () => {
      const stmts = parse(
        'log {"title": "Jurassic Park", "director": { "name": "Steven Spielberg" } }'
      )
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(DictionaryExpression)
      const mapExpr = logStmt.expression as DictionaryExpression
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

  describe('key access', () => {
    test('literal', () => {
      const stmts = parse(`log {"f": "o", "o": "b", "a": "r"}["o"] `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getExpr = logStmt.expression as GetElementExpression
      expect(getExpr.obj).toBeInstanceOf(DictionaryExpression)
      expect(getExpr.field).toBeInstanceOf(LiteralExpression)

      const elems = (getExpr.obj as DictionaryExpression).elements
      // take a map of key -> object, and turn it into key -> object.value
      const as_h = {}
      elems.forEach((value, key) => {
        as_h[key] = (value as LiteralExpression).value
      })

      expect(as_h).toEqual({ a: 'r', f: 'o', o: 'b' })
      expect((getExpr.field as LiteralExpression).value).toBe('o')
    })

    test('expression', () => {
      const stmts = parse(`log {"f": "o", "o": "b", "a": "r"}[something] `)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(LogStatement)
      const logStmt = stmts[0] as LogStatement
      expect(logStmt.expression).toBeInstanceOf(GetElementExpression)
      const getExpr = logStmt.expression as GetElementExpression
      expect(getExpr.obj).toBeInstanceOf(DictionaryExpression)
      expect(getExpr.field).toBeInstanceOf(VariableLookupExpression)

      const elems = (getExpr.obj as DictionaryExpression).elements
      // take a map of key -> object, and turn it into key -> object.value
      const as_h = {}
      elems.forEach((value, key) => {
        as_h[key] = (value as LiteralExpression).value
      })

      expect(as_h).toEqual({ a: 'r', f: 'o', o: 'b' })

      const varExpr = getExpr.field as VariableLookupExpression
      expect(varExpr.name.lexeme).toBe('something')
    })
  })

  describe('change element', () => {
    test('to a string', () => {
      const stmts = parse(`change scores[2] to "Hello"`)
      expect(stmts).toBeArrayOfSize(1)
      expect(stmts[0]).toBeInstanceOf(ChangeElementStatement)

      const changeStmt = stmts[0] as ChangeElementStatement
      expect(changeStmt.object).toBeInstanceOf(VariableLookupExpression)
      const lookupExpr = changeStmt.object as VariableLookupExpression
      expect(lookupExpr.name.lexeme).toBe('scores')

      expect(changeStmt.field).toBeInstanceOf(LiteralExpression)
      const indexExpr = changeStmt.field as LiteralExpression
      expect(indexExpr.value).toBe(2)
    })

    test('to a variable', () => {
      const stmts = parse(`change scores[foo] to 1`)
      expect(stmts).toBeArrayOfSize(1)
      const changeStmt = stmts[0] as ChangeElementStatement
      expect(changeStmt.field).toBeInstanceOf(VariableLookupExpression)
      const indexExpr = changeStmt.field as VariableLookupExpression
      expect(indexExpr.name.lexeme).toBe('foo')
    })

    test('to a function call', () => {
      const stmts = parse(`change scores[foo()] to 1`)
      expect(stmts).toBeArrayOfSize(1)
      const changeStmt = stmts[0] as ChangeElementStatement
      expect(changeStmt.field).toBeInstanceOf(FunctionCallExpression)
      const indexExpr = changeStmt.field as FunctionCallExpression
      expect(indexExpr.callee.name.lexeme).toBe('foo')
    })

    test.skip('chained', () => {
      const stmts = parse(`
                  set movie to {"director": {"name": "Peter Jackson"}}
                  change movie["director"]["name"] to "James Cameron"
                `)
      expect(stmts).toBeArrayOfSize(2)
      expect(stmts[0]).toBeInstanceOf(SetVariableStatement)
      expect(stmts[1]).toBeInstanceOf(ChangeElementStatement)

      const exprStmt = stmts[1] as ChangeElementStatement
      expect(exprStmt.value).toBeInstanceOf(SetElementExpression)

      const setExpr = exprStmt.value as SetElementExpression
      expect(setExpr.value).toBeInstanceOf(LiteralExpression)
      expect((setExpr.value as LiteralExpression).value).toBe('James Cameron')
      expect(setExpr.field.literal).toBe('name')
      expect(setExpr.obj).toBeInstanceOf(GetElementExpression)
      const getExpr = setExpr.obj as GetElementExpression
      expect(getExpr.obj).toBeInstanceOf(VariableLookupExpression)
      expect((getExpr.obj as VariableLookupExpression).name.lexeme).toBe(
        'movie'
      )
      expect(getExpr.field).toBe('director')
    })
  })
})

describe('execute', () => {
  describe('init', () => {
    test('empty', () => {
      const { frames } = interpret(`set movie to {}`)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({ movie: {} })
    })

    test('single element', () => {
      const { frames } = interpret(`set movie to {"title": "Jurassic Park"}`)
      expect(frames).toBeArrayOfSize(1)
      expect(frames[0].status).toBe('SUCCESS')

      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        movie: { title: 'Jurassic Park' },
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
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        movie: { title: 'The Matrix' },
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
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
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        movie: { director: { name: 'Peter Jackson' } },
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        movie: { director: { name: 'Peter Jackson' } },
        name: 'Peter Jackson',
      })
    })
  })

  describe('set', () => {
    test('single field', () => {
      const { frames } = interpret(`
        set movie to {"title": "The Matrix"}
        change movie["title"] to "Gladiator"
      `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        movie: { title: 'The Matrix' },
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        movie: { title: 'Gladiator' },
      })
    })

    test('chained', () => {
      const { error, frames } = interpret(`
          set movie to {"director": {"name": "Peter Jackson"}}
          change movie["director"]["name"] to "James Cameron"
        `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        movie: { director: { name: 'Peter Jackson' } },
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        movie: { director: { name: 'James Cameron' } },
      })
    })

    test('chained new field', () => {
      const { error, frames } = interpret(`
          set movie to {"director": {"name": "Peter Jackson"}}
          change movie["director"]["skill"] to 10
        `)
      expect(frames).toBeArrayOfSize(2)
      expect(frames[0].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[0].variables)).toMatchObject({
        movie: { director: { name: 'Peter Jackson' } },
      })
      expect(frames[1].status).toBe('SUCCESS')
      expect(unwrapJikiObject(frames[1].variables)).toMatchObject({
        movie: { director: { name: 'Peter Jackson', skill: 10 } },
      })
    })
  })
})
