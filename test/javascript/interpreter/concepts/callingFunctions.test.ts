import { parse } from '@/interpreter/parser'
import { interpret } from '@/interpreter/interpreter'
import { changeLanguage } from '@/interpreter/translator'
import { FunctionStatement, ReturnStatement } from '@/interpreter/statement'
import { last } from 'lodash'
import { unwrapJikiObject } from '@/interpreter/jikiTypes'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})
describe('function', () => {
  describe('parse', () => {})
  describe('interpret', () => {
    describe('pass by value', () => {
      test('lists', () => {
        const { frames } = interpret(`
        set original to [1, 2, 3]
        function increment with list do
          change list[1] to list[1] + 1
          change list[2] to list[2] + 1
          change list[3] to list[3] + 1
        end
        increment(original)
        log original
      `)
        // Inside the function
        const finalFunctionFrame = frames[frames.length - 3]
        expect(unwrapJikiObject(finalFunctionFrame.variables)['list']).toEqual([
          2, 3, 4,
        ])

        // After the function
        const lastFrame = frames[frames.length - 1]
        expect(unwrapJikiObject(lastFrame.variables)['original']).toEqual([
          1, 2, 3,
        ])
      })
    })
  })
})
