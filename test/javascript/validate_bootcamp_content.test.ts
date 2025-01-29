import { evaluateFunction, interpret } from '@/interpreter/interpreter'
import fs from 'fs'
import path from 'path'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import { Exercise } from '@/components/bootcamp/SolveExercisePage/exercises/Exercise'
import { camelize, camelizeKeys } from 'humps'
import { filteredStdLibFunctions } from '@/interpreter/stdlib'

const contentDir = path.resolve(__dirname, '../../bootcamp_content/projects')

function getSubdirectories(dir) {
  return fs
    .readdirSync(dir)
    .filter((file) => fs.statSync(path.join(dir, file)).isDirectory())
}

function getConfig(exerciseDir) {
  const configPath = path.join(exerciseDir, 'config.json')
  return JSON.parse(fs.readFileSync(configPath, 'utf-8'))
}

function getExampleScript(exerciseDir) {
  const examplePath = path.join(exerciseDir, 'example.jiki')
  return fs.readFileSync(examplePath, 'utf-8')
}

function testIo(project, exerciseSlug, config, task, testData, exampleScript) {
  test(`${project} - ${exerciseSlug} - ${task.name} - ${testData.name}`, () => {
    let error, value, frames
    try {
      ;({ error, value, frames } = evaluateFunction(
        exampleScript,
        {
          externalFunctions: filteredStdLibFunctions(config.stdlibFunctions),
        },
        testData.function,
        ...testData.params
      ))
    } catch (e) {
      expect(true).toBe(false)
    }

    // if(value != testData.expected.return) {
    //   console.log(error, value, frames);
    // }
    expect(value).toEqual(testData.expected)
  })
}

function testState(
  project,
  exerciseSlug,
  config,
  task,
  testData,
  exampleScript
) {
  test(`${project} - ${exerciseSlug} - ${task.name}`, () => {
    const Project = exerciseMap.get(config.projectType)
    const exercise: Exercise = new Project()

    ;(testData.setupFunctions || []).forEach((functionData) => {
      let [functionName, params] = functionData
      if (!params) {
        params = []
      }
      exercise[functionName](undefined, ...params)
    })

    const stdlibFunctions = filteredStdLibFunctions(config.stdlibFunctions)
    let exerciseFunctions = exercise.availableFunctions || []
    if (
      config.exerciseFunctions !== null &&
      config.exerciseFunctions !== undefined
    ) {
      exerciseFunctions = exerciseFunctions.filter((func) =>
        config.exerciseFunctions.includes(func.name)
      )
    }
    const externalFunctions = stdlibFunctions.concat(exerciseFunctions)

    const context = {
      externalFunctions: exerciseFunctions,
      languageFeatures: config.interpreterOptions,
    }
    let evaluated
    if (testData.function) {
      evaluated = evaluateFunction(exampleScript, context, testData.function)
    } else {
      evaluated = interpret(exampleScript, context)
    }

    const state = exercise.getState()

    testData.checks.forEach((check) => {
      const matcher = check.matcher || 'toEqual'

      // check can either be a reference to the final state or a function call.
      // We pivot on that to determine the actual value
      let actual

      // If it's a function call, we split out any params and then call the function
      // on the exercise with those params passed in.
      if (check.name.includes('(') && check.name.endsWith(')')) {
        const fnName = check.name.slice(0, check.name.indexOf('('))
        const argsString = check.name.slice(check.name.indexOf('(') + 1, -1)

        // We eval the args to turn numbers into numbers, strings into strings, etc.
        const safe_eval = eval // https://esbuild.github.io/content-types/#direct-eval
        const args =
          argsString === ''
            ? []
            : argsString.split(',').map((arg) => safe_eval(arg.trim()))

        // And then we get the function and call it.
        const fn = exercise[fnName]
        actual = fn.bind(exercise).call(exercise, evaluated, ...args)
      }

      // Our normal state is much easier! We just check the state object that
      // we've retrieved above via getState() for the variable in question.
      else {
        actual = state[check.name]
      }

      expect(actual)[matcher](check.value)
    })
  })
}

describe('Exercise Tests', () => {
  const projects = getSubdirectories(contentDir)

  projects.forEach((project) => {
    const projectDir = contentDir + '/' + project + '/exercises'
    const exercises = getSubdirectories(projectDir)
    exercises.forEach((exercise) => {
      const exerciseDir = path.join(projectDir, exercise)
      const config = camelizeKeys(getConfig(exerciseDir))
      const exampleScript = getExampleScript(exerciseDir)

      if (config.testsType == 'io') {
        config.tasks.forEach((task) => {
          task.tests.forEach((testData) => {
            testIo(project, exercise, config, task, testData, exampleScript)
          })
        })
      } else {
        config.tasks.forEach((task) => {
          task.tests.forEach((testData) => {
            testState(project, exercise, config, task, testData, exampleScript)
          })
        })
      }
    })
  })
})
