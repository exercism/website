import { describe } from '..'
import exerciseMap, {
  type Project,
} from '@/components/bootcamp/JikiscriptExercisePage/utils/exerciseMap'
import { execTest } from './execTest'
import { type TestRunnerOptions } from '@/components/bootcamp/types/TestRunner'
import { EditorView } from 'codemirror'
import { InformationWidgetData } from '../../CodeMirror/extensions/end-line-information/line-information'

export async function generateAndRunTestSuite(
  options: TestRunnerOptions,
  stateSetters: {
    setUnderlineRange: (range: { from: number; to: number }) => void
    setHighlightedLine: (line: number) => void
    setHighlightedLineColor: (color: string) => void
    setShouldShowInformationWidget: (shouldShow: boolean) => void
    setInformationWidgetData: (data: InformationWidgetData) => void
  },
  editorView: EditorView | null,
  language: Exercise['language']
) {
  return await describe(options.config.title, async (test) => {
    let project: Project | undefined
    if (options.config.projectType) {
      project = exerciseMap.get(options.config.projectType)
    }

    await mapTasks(test, options, editorView, stateSetters, language, project)
  })
}
const mapTasks = async (
  test,
  options,
  editorView,
  stateSetters,
  language,
  project
) => {
  for (const taskData of options.tasks) {
    for (const testData of taskData.tests) {
      await test(testData.name, testData.descriptionHtml, async () => {
        const result = await execTest(
          testData,
          options,
          editorView,
          stateSetters,
          language,
          project
        )

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
