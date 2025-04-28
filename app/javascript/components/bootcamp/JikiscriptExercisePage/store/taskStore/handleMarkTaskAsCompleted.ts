import { processTasks } from './processTasks'
import type { TaskStore } from './taskStore'

export function handleMarkTaskAsCompleted(
  state: TaskStore,
  testResults: TestSuiteResult<NewTestResult>
) {
  // once all tasks are completed, we don't need to do anything
  // even if they break the tests, the tasks will remain completed
  if (!state.tasks || !testResults || state.areAllTasksCompleted) return

  const taskData = processTasks(state, testResults)
  if (!taskData) return

  return {
    tasks: taskData.updatedTasks,
    ...taskData,
  }
}
