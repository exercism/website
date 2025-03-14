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
  SolveExercisePageProps,
  'exercise' | 'code' | 'solution' | 'customFunctions'
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
    populateCustomFunctionsForInterpreter,

    activateCustomFunction,
  } = useCustomFunctionStore()

  useLayoutEffect(() => {
    initializeTasks(exercise.tasks, null)

    setCustomFunctionMetadataCollection(customFunctions.available)

    // populateCustomFunctionsForInterpreter(
    //   customFunctions.forInterpreter.map((acf) => {
    //     return { ...acf, arity: acf.arity }
    //   })
    // )

    // TODO replace this with an actual list of activated functions
    const activatedFunctions = customFunctions.available.filter(
      (fn) => fn.selected
    )
    activatedFunctions.forEach((fn) => activateCustomFunction(fn.name, ''))
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
