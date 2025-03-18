import {
  evaluateFunction,
  EvaluateFunctionResult,
  interpret,
} from '@/interpreter/interpreter'
import fs from 'fs'
import path from 'path'
import exerciseMap, {
  Project,
} from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import { Exercise } from '@/components/bootcamp/SolveExercisePage/exercises/Exercise'
import { parseArgs } from '@/components/bootcamp/SolveExercisePage/test-runner/generateAndRunTestSuite/parseArgs'
import { Camelized, camelizeKeys } from 'humps'
import { filteredStdLibFunctions } from '@/interpreter/stdlib'
import checkers from '@/components/bootcamp/SolveExercisePage/test-runner/generateAndRunTestSuite/checkers'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'
import { execTest } from '@/components/bootcamp/SolveExercisePage/test-runner/generateAndRunTestSuite/execTest'
import { TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'

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

describe('Exercise Tests', () => {
  const projects = getSubdirectories(contentDir)

  projects.forEach((project) => {
    const projectDir = contentDir + '/' + project + '/exercises'
    const exercises = getSubdirectories(projectDir)
    exercises.forEach((exercise) => {
      const exerciseDir = path.join(projectDir, exercise)
      const config = camelizeKeysAs<any>(getConfig(exerciseDir))
      const exampleScript = getExampleScript(exerciseDir)

      let projectClass: Project | undefined
      if (config.projectType) {
        projectClass = exerciseMap.get(config.projectType)
      }
      const options = {
        studentCode: exampleScript,
        tasks: [],
        config: config,
      }

      config.tasks.forEach((task) => {
        task.tests.forEach((testData) => {
          if (testData.skipCi) return

          test(`${project} - ${exercise} - ${task.name} - ${testData.name}`, () => {
            const res = execTest(testData, options, projectClass)
            res.expects.forEach((exp) => {
              expect(exp.actual)[exp.matcher](exp.expected)
            })
          })
        })
      })
    })
  })
})
