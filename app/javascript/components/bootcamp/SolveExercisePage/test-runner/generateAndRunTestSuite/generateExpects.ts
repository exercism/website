import { expect } from '../expect'
import type { Exercise } from '../../exercises/Exercise'
import { InterpretResult } from '@/interpreter/interpreter'

export function generateExpects(
  testsType: 'io' | 'state',
  interpreterResult: InterpretResult,
  testData: TaskTest,
  { exercise, actual }: { exercise?: Exercise; actual?: any }
) {
  if (testsType == 'state') {
    return generateExpectsForStateTests(exercise!, interpreterResult, testData)
  } else {
    return generateExpectsForIoTests(testData, actual)
  }
}

// These are normal function in/out tests. We always know the actual value at this point
// (as it's returned from the function) so we can just compare it to the check value.
function generateExpectsForIoTests(testData: TaskTest, actual: any) {
  const matcher = testData.matcher || 'toEqual'

  return [
    // for now let's always include a label
    expect({
      actual,
      testsType: 'io',
      name: testData.name,
      slug: testData.slug,
    })[matcher as AvailableMatchers](testData.expected),
  ]
}

// These are the state tests, where we're comparing mutiple different variables or functions
// on the resulting exercise.
function generateExpectsForStateTests(
  exercise: Exercise,
  interpreterResult: InterpretResult,
  testData: TaskTest
) {
  // We only need to do this once, so do it outside the loop.
  const state = exercise.getState()

  return testData.checks!.map((check) => {
    const matcher = check.matcher || 'toEqual'

    // Check can either be a reference to the final state or a function call.
    // We pivot on that to determine the actual value
    let actual

    // If it's a function call, we split out any params and then call the function
    // on the exercise with those params passed in.
    if (check.name.includes('(') && check.name.endsWith(')')) {
      const fnName = check.name.slice(0, check.name.indexOf('('))
      const argsString = check.name.slice(check.name.indexOf('(') + 1, -1)

      // We eval the args to turn numbers into numbers, strings into strings, etc.
      const safe_eval = eval // https://esbuild.github.io/content-types/#direct-eval
      const args = safe_eval(`[${argsString}]`)

      // And then we get the function and call it.
      const fn = exercise[fnName]
      actual = fn.bind(exercise).call(exercise, interpreterResult, ...args)
    }

    // Our normal state is much easier! We just check the state object that
    // we've retrieved above via getState() for the variable in question.
    else {
      actual = state[check.name]
    }

    const errorHtml = check.errorHtml?.replaceAll('%actual%', actual) || ''

    return expect({
      ...check,
      testsType: 'state',
      actual,
      errorHtml,
      name: check.label ?? check.name,
    })[matcher as AvailableMatchers](check.value)
  })
}
