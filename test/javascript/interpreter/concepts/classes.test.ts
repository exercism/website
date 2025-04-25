import { parse } from '@/interpreter/parser'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import {
  ChangePropertyStatement,
  ClassStatement,
  ConstructorStatement,
  LogStatement,
  MethodCallStatement,
  MethodStatement,
  PropertyStatement,
  SetPropertyStatement as SetPropertyStatement,
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

    test('with this.setter', () => {
      const stmts = parse(`
        class Foobar do
          constructor do
            set this.foo to 10
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        ConstructorStatement
      )
      const constructorStatement = (stmts[0] as ClassStatement)
        .body[0] as ConstructorStatement
      expect(constructorStatement.parameters).toBeEmpty()
      expect(constructorStatement.body).toBeArrayOfSize(1)
      expect(constructorStatement.body[0]).toBeInstanceOf(SetPropertyStatement)
      const setPropertyStatement = constructorStatement
        .body[0] as SetPropertyStatement
      expect(setPropertyStatement.property.lexeme).toBe('foo')
      expect(setPropertyStatement.value).toBeInstanceOf(LiteralExpression)
      expect((setPropertyStatement.value as LiteralExpression).value).toBe(10)
    })
    test('with this.changer', () => {
      const stmts = parse(`
        class Foobar do
          constructor do
            set this.foo to 10
            change this.foo to 15
          end
        end
      `)
      expect((stmts[0] as ClassStatement).body[0]).toBeInstanceOf(
        ConstructorStatement
      )
      const constructorStatement = (stmts[0] as ClassStatement)
        .body[0] as ConstructorStatement
      expect(constructorStatement.parameters).toBeEmpty()
      expect(constructorStatement.body).toBeArrayOfSize(2)
      expect(constructorStatement.body[1]).toBeInstanceOf(
        ChangePropertyStatement
      )
      const changePropertyStatement = constructorStatement
        .body[1] as ChangePropertyStatement
      expect(changePropertyStatement.property.lexeme).toBe('foo')
      expect(changePropertyStatement.value).toBeInstanceOf(LiteralExpression)
      expect((changePropertyStatement.value as LiteralExpression).value).toBe(
        15
      )
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

describe('execute', () => {
  test('class instatiation', () => {
    const { error, frames } = interpret(`
      class Foobar do
      end
      set foo to new Foobar()
    `)
    expect(error).toBeNull()
    expect(frames).toBeArrayOfSize(1)
    expect(frames[0].status).toBe('SUCCESS')
    expect(frames[0].variables.foo).toBeInstanceOf(Jiki.Instance)
  })

  describe('constructor', () => {
    describe('naked - does nothing', () => {
      test('class instatiation', () => {
        const { error, frames } = interpret(`
          class Foobar do
            constructor do
            end
          end
          set foo to new Foobar()
        `)
        expect(error).toBeNull()
        expect(frames).toBeArrayOfSize(1)
        expect(frames[0].status).toBe('SUCCESS')
        expect(frames[0].variables.foo).toBeInstanceOf(Jiki.Instance)
      })
    })
    describe('naked - sets property', () => {
      test('class instatiation', () => {
        const { error, frames } = interpret(`
          class Foobar do
            public property baz

            constructor do
              set this.baz to 10
            end
          end
          set foo to new Foobar()
          set outer_baz to foo.baz
        `)
        expect(error).toBeNull()
        expect(frames).toBeArrayOfSize(3)
        expect(frames.at(-1)?.status).toBe('SUCCESS')
        expect(
          Jiki.unwrapJikiObject(frames.at(-1)?.variables['outer_baz'])
        ).toBe(10)
      })
    })
  })
  describe('method', () => {
    test('simple', () => {
      const { error, frames } = interpret(`
        class Foobar do
          public method do_it do
            return 10
          end
        end
        set foo to new Foobar()
        set outer_baz to foo.do_it()
      `)
      expect(error).toBeNull()
      expect(frames).toBeArrayOfSize(3)
      expect(frames.at(-1)?.status).toBe('SUCCESS')
      expect(Jiki.unwrapJikiObject(frames.at(-1)?.variables['outer_baz'])).toBe(
        10
      )
    })
    test('with this', () => {
      const { error, frames } = interpret(`
        class Foobar do
          public property baz

          constructor do
            set this.baz to 10
          end

          public method do_it do
            return this.baz
          end
        end
        set foo to new Foobar()
        set outer_baz to foo.do_it()
      `)
      console.log(frames.at(-1))
      expect(error).toBeNull()
      expect(frames).toBeArrayOfSize(4)
      expect(frames.at(-1)?.status).toBe('SUCCESS')
      expect(Jiki.unwrapJikiObject(frames.at(-1)?.variables['outer_baz'])).toBe(
        10
      )
    })
  })
  test.skip('Complex methods', () => {
    const { error, frames } = interpret(`
      class Foobar do
        public property baz

        constructor do
          set this.baz to 10
        end

        private method updater with value do
          set this.baz to value
          return this.baz
          end

        public method do_it with value do
          return this.updater(value)
        end
      end
      set foo to new Foobar()
      set outer_baz to foo.do_it(20)
    `)
    expect(error).toBeNull()
    expect(frames).toBeArrayOfSize(6)
    expect(frames.at(-1)?.status).toBe('SUCCESS')
    expect(Jiki.unwrapJikiObject(frames.at(-1)?.variables['outer_baz'])).toBe(
      20
    )
  })
  test('Another example', () => {
    const { error, frames } = interpret(`
      class RaindropsCollector do
        private property numbers
        constructor do
          set this.numbers to []
        end

        public method add_number with number do
          change this.numbers to [number]
        end
      end
      set collector to new RaindropsCollector()
      collector.add_number(10)
    `)
    expect(error).toBeNull()
    expect(frames.at(-1)?.status).toBe('SUCCESS')
  })
})
