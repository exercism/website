import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseParams } from '../test-runner/generateAndRunTestSuite/parseParams'
import { ExerciseLocalStorageData } from '../SolveExercisePageContextWrapper'

export function useSetupStores({
  exercise,
  code,
}: Pick<SolveExercisePageProps, 'exercise' | 'code'> & {
  exerciseLocalStorageData: ExerciseLocalStorageData
}) {
  const {
    initializeTasks,
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
  } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  useLayoutEffect(() => {
    initializeTasks(exercise.tasks, null, false)
    setFlatPreviewTaskTests(
      exercise.tasks.flatMap((task) => {
        // we don't show bonus tasks in the preview.
        if (task.bonus) return []

        return task.tests.map((test) => {
          if (!test.params) return test
          test.params = parseParams(test.params)
          return test
        })
      })
    )
  }, [
    exercise,
    code,
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
    setWasFinishLessonModalShown,
  ])
}
