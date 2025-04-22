import { describe } from '..'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/JikiscriptExercisePage/utils/exerciseMap'
import { execTest } from './execTest'
import { type TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'
import { EditorView } from 'codemirror'

export async function generateAndRunTestSuite(
  options: TestRunnerOptions,
  editorView: EditorView | null
) {
  return await describe(options.config.title, async (test) => {
    let project: Project | undefined
    if (options.config.projectType) {
      project = exerciseMap.get(options.config.projectType)
    }

    await mapTasks(test, options, editorView, project)
  })
}
const mapTasks = async (test, options, editorView, project) => {
  for (const taskData of options.tasks) {
    for (const testData of taskData.tests) {
      await test(testData.name, testData.descriptionHtml, async () => {
        const result = await execTest(testData, options, editorView, project)

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
    }
  }
}

export default generateAndRunTestSuite
