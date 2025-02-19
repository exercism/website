import { evaluateFunction } from '@/interpreter/interpreter'
import { generateExpects } from './generateExpects'
import { TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'
import { filteredStdLibFunctions } from '@/interpreter/stdlib'
import { generateCodeRunString } from '../../utils/generateCodeRunString'
import { parseParams } from './parseParams'

const customFunctions = [
  {
    name: 'my#length',
    arity: 1,
    code: `
    function my#length with string do
    set counter to 0
    for each character in string do
      change counter to counter + 1
      end
    return counter
  end`,
  },
]

/**
 This is of type TestCallback
 */
export function execGenericTest(
  testData: TaskTest,
  options: TestRunnerOptions
): ReturnType<TestCallback> {
  const params = testData.params || []

  const context = {
    externalFunctions: filteredStdLibFunctions(options.config.stdlibFunctions),
    customFunctions,
    languageFeatures: options.config.interpreterOptions,
  }

  const parsedParams = parseParams(params)

  const evaluated = evaluateFunction(
    options.studentCode,
    context,
    testData.function,
    ...parsedParams
  )

  if (evaluated.error) {
    console.error('Evaluation error:', evaluated.error)
  }

  const { value: actual, frames } = evaluated

  const codeRun = generateCodeRunString(testData.function, parsedParams)

  const expects = generateExpects(
    options.config.testsType,
    evaluated,
    testData,
    {
      actual,
    }
  )

  return {
    expects,
    slug: testData.slug,
    codeRun,
    frames,
    animationTimeline: null,
    imageSlug: testData.imageSlug,
  }
}
