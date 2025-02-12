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
        const { tests } = task

        const newTests = tests.map((test) => {
          if (!test.params) return test
          test.params = parseParams(test.params)
          return test
        })

        return newTests
      })
    )
  }, [exercise, code, setWasFinishLessonModalShown])
}
