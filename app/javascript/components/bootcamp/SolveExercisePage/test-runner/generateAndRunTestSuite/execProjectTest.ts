import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import { type Project } from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import type { Exercise } from '../../exercises/Exercise'
import { AnimationTimeline } from '../../AnimationTimeline/AnimationTimeline'
import { generateExpects } from './generateExpects'
import { TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'
import { filteredStdLibFunctions } from '@/interpreter/stdlib'

/**
 This is of type TestCallback
 */
export function execProjectTest(
  Project: Project,
  testData: TaskTest,
  options: TestRunnerOptions
): ReturnType<TestCallback> {
  const exercise: Exercise = new Project()

  // Choose the functions that are available to the student from config.stdlibFunctions
  const stdlibFunctions = filteredStdLibFunctions(
    options.config.stdlibFunctions
  )
  let exerciseFunctions = exercise.availableFunctions || []
  if (options.config.exerciseFunctions !== null) {
    exerciseFunctions = exerciseFunctions.filter((func) =>
      options.config.exerciseFunctions.includes(func.name)
    )
  }
  const externalFunctions = stdlibFunctions.concat(exerciseFunctions)

  const context = {
    externalFunctions,
    languageFeatures: options.config.interpreterOptions,
  }

  ;(testData.setupFunctions || []).forEach((functionData) => {
    let [functionName, params] = functionData
    if (!params) {
      params = []
    }
    exercise[functionName](...params)
  })

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
