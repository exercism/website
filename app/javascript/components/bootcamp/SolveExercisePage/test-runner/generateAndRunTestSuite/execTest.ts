import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import { generateExpects } from './generateExpects'
import { TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'
import { filteredStdLibFunctions } from '@/interpreter/stdlib'
import { generateCodeRunString } from '../../utils/generateCodeRunString'
import { parseArgs } from './parseArgs'
import { type Project } from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import type { Exercise } from '../../exercises/Exercise'
import { AnimationTimeline } from '../../AnimationTimeline/AnimationTimeline'

/**
 This is of type TestCallback
 */
export function execTest(
  testData: TaskTest,
  options: TestRunnerOptions,
  project?: Project
): ReturnType<TestCallback> {
  const exercise: Exercise | undefined = project ? new project() : undefined
  runSetupFunctions(exercise, testData.setupFunctions || [])

  const context = {
    externalFunctions: buildExternalFunctions(options, exercise),
    classes: exercise?.availableClasses || [],
    languageFeatures: options.config.interpreterOptions,
  }

  const args = testData.args ? parseArgs(testData.args) : []

  let evaluated
  if (testData.function) {
    evaluated = evaluateFunction(
      options.studentCode,
      context,
      testData.function,
      ...args
    )
  } else {
    evaluated = interpret(options.studentCode, context)
  }

  const { value: actual, frames } = evaluated
  const codeRun = generateCodeRunString(testData.function, args)

  let animationTimeline: AnimationTimeline | null = null
  if (exercise) {
    const { animations } = exercise
    animationTimeline = buildAnimationTimeline(exercise, frames, animations)
  }

  const expects = generateExpects(evaluated, testData, actual, exercise)

  return {
    expects,
    slug: testData.slug,
    codeRun,
    frames,
    type: options.config.testsType || (exercise ? 'state' : 'io'),
    animationTimeline,
    imageSlug: testData.imageSlug,
    view: exercise?.getView(),
  }
}

const buildExternalFunctions = (
  options: TestRunnerOptions,
  exercise: Exercise | undefined
) => {
  const externalFunctions = filteredStdLibFunctions(
    options.config.stdlibFunctions
  )
  if (!exercise) return externalFunctions

  let exerciseFunctions = exercise.availableFunctions || []
  if (options.config.exerciseFunctions) {
    exerciseFunctions = exerciseFunctions.filter((func) =>
      options.config.exerciseFunctions.includes(func.name)
    )
  }
  return externalFunctions.concat(exerciseFunctions)
}

const runSetupFunctions = (
  exercise: Exercise | undefined,
  setupFunctions: SetupFunction[]
) => {
  if (!exercise) return

  setupFunctions.forEach((functionData) => {
    let [functionName, params] = functionData
    if (!params) {
      params = []
    }
    if (typeof exercise[functionName] === 'function') {
      ;(exercise[functionName] as Function)(null, ...params)
    }
  })
}
function buildAnimationTimeline(exercise, frames, animations) {
  if (!animations || animations.length == 0) {
    return null
  }

  let animationsForTimeline = animations

  // If we've got an infinite loop, then don't add the millions of animations
  // to the timeline if we know it hurts on that exercise.
  const lastFrame = frames.at(-1)
  if (
    !exercise.showAnimationsOnInfiniteLoops &&
    lastFrame.status === 'ERROR' &&
    (lastFrame.error.type == 'MaxIterationsReached' ||
      lastFrame.error.type == 'InfiniteRecursion')
  ) {
    animationsForTimeline = []
  }
  return new AnimationTimeline({}, frames).populateTimeline(
    animationsForTimeline
  )
}
