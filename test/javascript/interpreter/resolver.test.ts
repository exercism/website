import { type Context } from '@/interpreter/interpreter'
import { parse } from '@/interpreter/languages/javascript/parser'
import { Resolver } from '@/interpreter/resolver'

export function resolve(sourceCode: string, context: Context = {}): void {
  const externalFunctions = context.externalFunctions || {}
  const functionNames = Object.keys(externalFunctions)
  const statements = parse(sourceCode, {
    functionNames: functionNames,
    languageFeatures: context.languageFeatures || {},
    shouldWrapTopLevelStatements: context.wrapTopLevelStatements || false,
  })
  new Resolver(false, functionNames).resolve(statements)
}

describe('error', () => {
  test('declare variable with same name more than once', () => {
    expect(() =>
      resolve(`
        {
          let a = 1
          let a = 2
        }
      `)
    ).toThrow('Already a variable with this name in this scope.')
  })

  describe('assign constant', () => {
    test('in same scope', () => {
      expect(() =>
        resolve(`
          const a = 1
          a = 2
        `)
      ).toThrow('Cannot re-assign value of constant.')
    })

    test('in parent scope', () => {
      expect(() =>
        resolve(`
          const a = 1
          {
            a = 2
          }
        `)
      ).toThrow('Cannot re-assign value of constant.')
    })
  })

  test('return outside of function', () => {
    expect(() => resolve('return 1')).toThrow(
      "Can't return from top-level code."
    )
  })
})
