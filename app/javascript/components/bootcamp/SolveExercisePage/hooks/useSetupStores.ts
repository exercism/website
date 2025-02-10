import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseParams } from '../test-runner/generateAndRunTestSuite/parseParams'

export function useSetupStores({
  exercise,
  code,
  solution,
}: Pick<SolveExercisePageProps, 'exercise' | 'solution' | 'code'>) {
  const { initializeTasks, setShouldShowBonusTasks } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  useLayoutEffect(() => {
    setShouldShowBonusTasks(solution.passedBasicTests)
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
  }, [exercise, code])
}
