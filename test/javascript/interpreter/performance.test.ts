import { RuntimeErrorType } from '@/interpreter/error'
import { Frame } from '@/interpreter/frames'
import { EvaluationContext, interpret } from '@/interpreter/interpreter'
import { Location, Span } from '@/interpreter/location'
import { changeLanguage } from '@/interpreter/translator'
import * as Jiki from '@/interpreter/jikiObjects'

beforeAll(() => {
  changeLanguage('system')
})

afterAll(() => {
  changeLanguage('en')
})

const boundlessContext = {
  languageFeatures: {
    maxTotalLoopIterations: 100000000,
    maxTotalExecutionTime: 100000000,
  },
}

test('Simple repeat', () => {
  const code = `repeat 100000 times indexed by idx do
  end`

  const t = performance.now()
  const { frames } = interpret(code, boundlessContext)
  // 350ms is roughly how long it takes on GHA
  expect(performance.now() - t).toBeLessThan(350)
  expect(frames[frames.length - 1].status).toBe('SUCCESS')
})
