import { evaluateFunction } from '@/interpreter/interpreter'
import { generateExpects } from './generateExpects'

/**
 This is of type TestCallback
 */
export function execGenericTest(
  testData: TaskTest,
  options: TestRunnerOptions
): ReturnType<TestCallback> {
  const params = testData.params || []

  const evaluated = evaluateFunction(
    options.studentCode,
    {
      language: 'JikiScript',
    },
    testData.function,
    ...params
  )

  if (evaluated.error) {
    console.error('Evaluation error:', evaluated.error)
  }

  const { value: actual, frames } = evaluated

  const codeRun = testData.function + '(' + params.join(', ') + ')'

  const expects = generateExpects(options.config.testsType, testData, {
    actual,
  })

  return {
    expects,
    slug: testData.slug,
    codeRun,
    frames,
    animationTimeline: null,
    imageSlug: testData.imageSlug,
  }
}
