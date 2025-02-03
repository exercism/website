import { evaluateFunction } from '@/interpreter/interpreter'
import { generateExpects } from './generateExpects'
import { TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'
import { filteredStdLibFunctions } from '@/interpreter/stdlib'
import { generateCodeRunString } from '../../utils/generateCodeRunString'
import { genericSetupFunctions } from './genericSetupFunctions'

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
    languageFeatures: options.config.interpreterOptions,
  }

  const parsedParams = params.map((elem) => {
    if (!(elem.startsWith('setup.') && elem.endsWith(')'))) {
      return elem
    }

    // Wild dark magic
    return new Function('setup', `"use strict"; return (${elem});`)(
      genericSetupFunctions
    )
  })

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
