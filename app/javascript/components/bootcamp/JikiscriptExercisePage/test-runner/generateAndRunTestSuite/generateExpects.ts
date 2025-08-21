import { expect } from '../expect'
import type { Exercise } from '../../exercises/Exercise'
import { InterpretResult } from '@/interpreter/interpreter'
import checkers from './checkers'
import { generateCodeRunString } from '../../utils/generateCodeRunString'

export function generateExpects(
  interpreterResult: InterpretResult,
  testData: TaskTest,
  actual: any,
  exercise?: Exercise
) {
  // We only need to do this once, so do it outside the loop.
  const state = exercise ? exercise.getState() : {}

  if (testData.checks === undefined) {
    throw 'No checks on this test!'
  }
  return testData.checks.map((check: ExpectCheck) => {
    const matcher = check.matcher || 'toEqual'

    // Check can either be a reference to the final state or a function call.
    // We pivot on that to determine the actual value
    let checkActual
    let codeRun

    // If it's a function call, we split out any params and then call the function
    // on the exercise with those params passed in.
    if (check.hasOwnProperty('function')) {
      check = check as ExpectCheckFunction

      let fnName
      let args
      if (check.function.includes('(') && check.function.endsWith(')')) {
        fnName = check.function.slice(0, check.function.indexOf('('))
        const argsString = check.function.slice(
          check.function.indexOf('(') + 1,
          -1
        )

        // We eval the args to turn numbers into numbers, strings into strings, etc.
        const safe_eval = eval // https://esbuild.github.io/content-types/#direct-eval
        args = safe_eval(`[${argsString}]`)
      } else {
        fnName = check.function
        args = check.args || []
      }

      // And then we get the function from either exercise or checkers and call it.
      const fn = exercise ? exercise[fnName].bind(exercise) : checkers[fnName]

      checkActual = fn.call(exercise, interpreterResult, ...args)
      codeRun = check.codeRun ? check.codeRun : undefined
    }

    // Our normal state is much easier! We just check the state object that
    // we've retrieved above via getState() for the variable in question.
    else if (check.hasOwnProperty('property')) {
      check = check as ExpectCheckProperty
      checkActual = state[check.property]
      codeRun = check.codeRun ? check.codeRun : undefined
    }

    // And the return state is easiest of all!
    else {
      checkActual = actual
    }

    const errorHtml = check.errorHtml?.replaceAll('%actual%', checkActual) || ''
    if (check.value == undefined) {
      check.value = "THIS SHOULDN'T BE UNDEFINED"
    }

    return expect({
      ...check,
      actual: checkActual,
      codeRun,
      errorHtml,
      matcher, // Useful for logging and the actual tests
    })[matcher as AvailableMatchers](check.value)
  })
}
