import { describe } from '..'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import { execProjectTest, execProjectTestAsync } from './execProjectTest'
import { execGenericTest } from './execGenericTest'
import { type TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'

export default (options: TestRunnerOptions) => {
  return describe(options.config.title, async (test) => {
    let project: Project | null = null
    if (options.config.projectType) {
      project = exerciseMap.get(options.config.projectType)
    }
    await mapTasks(test, options, project)
  })
}

const mapTasks = async (test, options, project) => {
  options.tasks.map((taskData) => {
    taskData.tests.map((testData) => {
      test(testData.name, async () => {
        let result: ReturnType<TestCallback>
        if (project) {
          result = await execProjectTestAsync(project, testData, options)
        } else {
          result = execGenericTest(testData, options)
        }

        const { frames } = result
        let { expects } = result

        // make sure a test is only successful if all frames are successful
        expects.push({
          actual: 'running',
          errorHtml: 'Your code has an error in it.',
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
}
