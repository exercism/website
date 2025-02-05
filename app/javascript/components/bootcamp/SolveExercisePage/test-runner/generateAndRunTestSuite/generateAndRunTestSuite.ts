import { describe } from '..'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import { execProjectTest } from './execProjectTest'
import { execGenericTest } from './execGenericTest'
import { type TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'

export default (options: TestRunnerOptions) => {
  return describe(options.config.title, (test) => {
    let project: Project | null = null
    if (options.config.projectType) {
      project = exerciseMap.get(options.config.projectType)
    }
    options.tasks.map((taskData) => {
      taskData.tests.map((testData) => {
        test(testData.name, () => {
          let result: ReturnType<TestCallback>
          if (project) {
            result = execProjectTest(project, testData, options)
          } else {
            result = execGenericTest(testData, options)
          }

          const { frames } = result
          let { expects } = result

          // make sure a test is only successful if all frames are successful
          expects.push({
            actual: 'running',
            errorHtml: 'Your code has an error',
            name: 'Code passes',
            expected: true,
            pass: frames.every((frame) => frame.status === 'SUCCESS'),
            slug: 'code-passes',
            testsType: 'state',
          })

          return { ...result, expects }
        })
      })
    })
  })
}
