import { useLayoutEffect } from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import useTestStore from '../store/testStore'

export function useSetupStores({
  exercise,
  code,
}: Pick<SolveExercisePageProps, 'exercise' | 'code'>) {
  const { initializeTasks } = useTaskStore()
  const { setFlatPreviewTaskTests } = useTestStore()

  useLayoutEffect(() => {
    initializeTasks(exercise.tasks, null)
    setFlatPreviewTaskTests(exercise.tasks.flatMap((task) => task.tests))
  }, [exercise, code])
}

export function generateCodeRunString(fn: string, params: any[]) {
  if (!fn || !params) return ''
  return `${fn}(${params.join(', ')})`
}
