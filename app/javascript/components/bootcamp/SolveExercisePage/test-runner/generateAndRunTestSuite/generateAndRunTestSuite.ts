import { describe } from '..'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/SolveExercisePage/utils/exerciseMap'
import { execProjectTest } from './execProjectTest'
import { execGenericTest } from './execGenericTest'
import { TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'

export default (options: TestRunnerOptions) => {
  return describe(options.config.title, (test) => {
    let project: Project | null = null
    if (options.config.projectType) {
      project = exerciseMap.get(options.config.projectType)
    }
    options.tasks.map((taskData) => {
      taskData.tests.map((testData) => {
        test(testData.name, () => {
          if (project) {
            return execProjectTest(project, testData, options)
          } else {
            return execGenericTest(testData, options)
          }
        })
      })
    })
  })
}
