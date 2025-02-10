import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseParams } from '../test-runner/generateAndRunTestSuite/parseParams'

export function useSetupStores({
  exercise,
  code,
}: Pick<SolveExercisePageProps, 'exercise' | 'code'>) {
  const { initializeTasks } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  useLayoutEffect(() => {
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
  }, [exercise, code])
}
