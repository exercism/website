import type { TaskStore } from './taskStore'

export function processTasks(
  state: TaskStore,
  testResults: TestSuiteResult<NewTestResult | PreviousTestResult>
) {
  const passingTests = new Set(
    testResults.tests
      .filter((test) => test.status === 'pass')
      .map((test) => test.name)
  )

  if (!state || !state.tasks || state.tasks.length === 0) {
    return {
      updatedTasks: [],
      numberOfCompletedTasks: 0,
      areAllTasksCompleted: true,
      activeTaskIndex: 0,
    }
  }

  const updatedTasks: Task[] = []
  let foundFirstInactiveTask = false
  let numberOfCompletedTasks = state.numberOfCompletedTasks ?? 0
  let activeTaskIndex = state.activeTaskIndex

  for (let i = 0; i < state.tasks.length; i++) {
    const task = state.tasks[i]

    // we don't want to degrade completed tasks to active if they were once completed
    if (task.status === 'completed') {
      updatedTasks.push(task)
      continue
    }

    // always set the task to completed if all tests are passing
    if (task.tests.every((test) => passingTests.has(test.name))) {
      updatedTasks.push({ ...task, status: 'completed' })
      numberOfCompletedTasks++
      continue
    }

    const hasAnActiveTask = updatedTasks.some(
      (task) => task.status === 'active'
    )
    // if doesn't have active task, find the first inactive task and set it to active
    if (
      !hasAnActiveTask &&
      !foundFirstInactiveTask &&
      task.status === 'inactive'
    ) {
      updatedTasks.push({ ...task, status: 'active' })
      activeTaskIndex = i
      foundFirstInactiveTask = true
      continue
    }

    updatedTasks.push(task)
  }

  const areAllTasksCompleted = numberOfCompletedTasks === updatedTasks.length

  return {
    updatedTasks,
    numberOfCompletedTasks,
    areAllTasksCompleted,
    activeTaskIndex,
  }
}
