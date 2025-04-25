import { processTasks } from './processTasks'
import type { TaskStore } from './taskStore'

export function getInitialTasks(
  tasks: Omit<Task, 'status'>[],
  testResults: TestSuiteResult<PreviousTestResult> | null
) {
  if (!testResults) {
    return {
      tasks: tasks.map((task, idx) => {
        return { ...task, status: idx === 0 ? 'active' : 'inactive' }
      }),
      numberOfTasks: tasks.length,
      numberOfCompletedTasks: 0,
      activeTaskIndex: 0,
      areAllTasksCompleted: false,
    }
  } else {
    const tasksWithStatus: Task[] = tasks.map((task) => {
      return {
        ...task,
        status: 'inactive',
      }
    })
    const processedTasks = processTasks(
      { tasks: tasksWithStatus, activeTaskIndex: 0 } as TaskStore,
      testResults
    )

    return {
      tasks: processedTasks.updatedTasks,
      numberOfTasks: tasks.length,
      numberOfCompletedTasks: processedTasks.numberOfCompletedTasks,
      activeTaskIndex: processedTasks.activeTaskIndex,
      areAllTasksCompleted: processedTasks.areAllTasksCompleted,
    }
  }
}
