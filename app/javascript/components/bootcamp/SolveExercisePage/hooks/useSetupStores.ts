import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseParams } from '../test-runner/generateAndRunTestSuite/parseParams'
import { ExerciseLocalStorageData } from '../SolveExercisePageContextWrapper'

export function useSetupStores({
  exercise,
  code,
  exerciseLocalStorageData,
}: Pick<SolveExercisePageProps, 'exercise' | 'code'> & {
  exerciseLocalStorageData: ExerciseLocalStorageData
}) {
  const { initializeTasks, setWasFinishLessonModalShown } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  useLayoutEffect(() => {
    setWasFinishLessonModalShown(
      !!exerciseLocalStorageData.wasFinishLessonModalShown
    )
    initializeTasks(exercise.tasks, null)
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
  }, [exercise, code, setWasFinishLessonModalShown])
}
