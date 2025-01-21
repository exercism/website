import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import { type Project } from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import type { Exercise } from '../../exercises/Exercise'
import { AnimationTimeline } from '../../AnimationTimeline/AnimationTimeline'
import { generateExpects } from './generateExpects'

/**
 This is of type TestCallback
 */
export function execProjectTest(
  Project: Project,
  testData: TaskTest,
  options: TestRunnerOptions
): ReturnType<TestCallback> {
  const exercise: Exercise = new Project()

  ;(testData.setupFunctions || []).forEach((functionData) => {
    let [functionName, params] = functionData
    if (!params) {
      params = []
    }
    exercise[functionName](...params)
  })

  console.log(options.config.interpreterOptions)
  const context = {
    externalFunctions: exercise.availableFunctions,
    language: 'JikiScript',
    languageFeatures: options.config.interpreterOptions,
  }
  let evaluated
  if (testData.function) {
    evaluated = evaluateFunction(
      options.studentCode,
      context,
      testData.function
    )
  } else {
    evaluated = interpret(options.studentCode, context)
  }

  const { frames } = evaluated

  const { animations } = exercise
  const animationTimeline =
    animations.length > 0
      ? new AnimationTimeline({}, frames).populateTimeline(animations)
      : null

  const expects = generateExpects(
    options.config.testsType,
    evaluated,
    testData,
    {
      exercise,
    }
  )

  return {
    expects,
    codeRun: '',
    frames,
    animationTimeline,
    view: exercise.getView(),
    slug: testData.slug,
  }
}
