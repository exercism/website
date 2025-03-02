import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseArgs } from '../test-runner/generateAndRunTestSuite/parseArgs'

export function useSetupStores({
  exercise,
  solution,
}: Pick<SolveExercisePageProps, 'exercise' | 'code' | 'solution'>) {
  const {
    initializeTasks,
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
    setShouldShowBonusTasks,
  } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  useLayoutEffect(() => {
    initializeTasks(exercise.tasks, null)

    setWasCompletedBonusTasksModalShown(solution.passedBonusTests)
    setWasFinishLessonModalShown(solution.passedBasicTests)
    setShouldShowBonusTasks(solution.passedBasicTests)
    setFlatPreviewTaskTests(
      exercise.tasks.flatMap((task) => {
        // we don't show bonus tasks in the preview.
        if (task.bonus) return []

        return task.tests.map((test) => {
          if (!test.params) return test
          test.params = parseArgs(test.params)
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
