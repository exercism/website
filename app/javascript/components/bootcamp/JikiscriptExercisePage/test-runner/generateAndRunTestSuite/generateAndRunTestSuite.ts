import { describe } from '..'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/JikiscriptExercisePage/utils/exerciseMap'
import { execTest } from './execTest'
import { type TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'

export default (options: TestRunnerOptions) => {
  return describe(options.config.title, (test) => {
    let project: Project | undefined
    if (options.config.projectType) {
      project = exerciseMap.get(options.config.projectType)
    }
    options.tasks.map((taskData) => {
      taskData.tests.map((testData) => {
        test(testData.name, testData.descriptionHtml, () => {
          const result = execTest(testData, options, project)

          const { frames, expects } = result

          // make sure a test is only successful if all frames are successful
          expects.push({
            actual: 'running',
            matcher: 'toBe',
            errorHtml: 'Your code has an error in it.',
            expected: true,
            pass: frames.every((frame) => frame.status === 'SUCCESS'),
          })

          return { ...result, expects }
        })
      })
    })
  })
}
