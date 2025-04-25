import fs from 'fs'
import path from 'path'
import exerciseMap, {
  Project,
} from '@/components/bootcamp/JikiscriptExercisePage/utils/exerciseMap'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'
import { execTest } from '@/components/bootcamp/JikiscriptExercisePage/test-runner/generateAndRunTestSuite/execTest'
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
    exercises.forEach(async (exercise) => {
      const exerciseDir = path.join(projectDir, exercise)
      const config = camelizeKeysAs<any>(getConfig(exerciseDir))

      if (config.language === 'javascript') {
        // we need at least one test
        expect('no validation for javascript').toBe(
          'no validation for javascript'
        )
        return
      }

      const exampleScript = getExampleScript(exerciseDir)

      let projectClass: Project | undefined
      if (config.projectType) {
        projectClass = exerciseMap.get(config.projectType)
      }
      const options: TestRunnerOptions = {
        studentCode: exampleScript,
        tasks: [],
        config: config,
        customFunctions: [],
      }

      config.tasks.forEach((task) => {
        task.tests.forEach(async (testData) => {
          if (testData.skipCi) return

          test(`${project} - ${exercise} - ${task.name} - ${testData.name}`, async () => {
            const res = await execTest(
              testData,
              options,
              null,
              {
                setHighlightedLine: () => {},
                setHighlightedLineColor: () => {},
                setInformationWidgetData: () => {},
                setShouldShowInformationWidget: () => {},
                setUnderlineRange: () => {},
              },
              'jikiscript',
              projectClass
            )
            res.expects.forEach((exp) => {
              expect(exp.actual)[exp.matcher](exp.expected)
            })
          })
        })
      })
    })
  })
})
