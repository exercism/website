import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'
import { parseParams } from '../test-runner/generateAndRunTestSuite/parseParams'
import useCustomFunctionStore from '../../CustomFunctionEditor/store/customFunctionsStore'

export function useSetupStores({
  exercise,
  solution,
  activeCustomFunctions,
  availableCustomFunctions,
}: Pick<
  SolveExercisePageProps,
  | 'exercise'
  | 'code'
  | 'solution'
  | 'activeCustomFunctions'
  | 'availableCustomFunctions'
>) {
  const {
    initializeTasks,
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
    setShouldShowBonusTasks,
  } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  const {
    setCustomFunctionMetadataCollection,
    setCustomFunctionsForInterpreter,
  } = useCustomFunctionStore()

  useLayoutEffect(() => {
    initializeTasks(exercise.tasks, null)

    setCustomFunctionMetadataCollection(availableCustomFunctions)
    setCustomFunctionsForInterpreter(
      activeCustomFunctions.map((acf) => {
        return { ...acf, arity: acf.fnArity }
      })
    )
    setWasCompletedBonusTasksModalShown(solution.passedBonusTests)
    setWasFinishLessonModalShown(solution.passedBasicTests)
    setShouldShowBonusTasks(solution.passedBasicTests)
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
    setWasFinishLessonModalShown,
    setWasCompletedBonusTasksModalShown,
    setWasFinishLessonModalShown,
  ])
}
