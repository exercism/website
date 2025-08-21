import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseArgs } from '../test-runner/generateAndRunTestSuite/parseArgs'
import useCustomFunctionStore from '../../CustomFunctionEditor/store/customFunctionsStore'

export function useSetupStores({
  exercise,
  solution,
  customFunctions,
}: Pick<
  JikiscriptExercisePageProps,
  'exercise' | 'code' | 'solution' | 'customFunctions'
>) {
  const {
    initializeTasks,
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
    setShouldShowBonusTasks,
  } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  const { initializeCustomFunctions } = useCustomFunctionStore()

  useLayoutEffect(() => {
    initializeTasks(exercise.tasks, null)

    initializeCustomFunctions(customFunctions)

    setWasCompletedBonusTasksModalShown(solution.passedBonusTests)
    setWasFinishLessonModalShown(solution.passedBasicTests)
    setShouldShowBonusTasks(solution.passedBasicTests)
    setFlatPreviewTaskTests(
      exercise.tasks.flatMap((task) => {
        // we don't show bonus tasks in the preview.
        if (task.bonus) return []

        return task.tests.map((test) => {
          if (!test.args) return test
          test.args = parseArgs(test.args)
          return test
        })
      })
    )
  }, [
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
    setWasFinishLessonModalShown,
  ])
}
