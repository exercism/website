import type { TaskStore } from './taskStore'

export function processTasks(
  state: TaskStore,
  testResults: TestSuiteResult<NewTestResult | PreviousTestResult>
) {
  const passingTests = new Set(
    testResults.tests
      .filter((test) => test.status === 'pass')
      .map((test) => test.slug)
  )

  if (!state || !state.tasks || state.tasks.length === 0) {
    return {
      updatedTasks: [],
      numberOfCompletedTasks: 0,
      areAllTasksCompleted: false,
      activeTaskIndex: 0,
    }
  }

  const updatedTasks: Task[] = []
  let foundFirstInactiveTask = false
  let numberOfCompletedTasks = state.numberOfCompletedTasks ?? 0
  let activeTaskIndex: number | undefined = state.activeTaskIndex

  for (let i = 0; i < state.tasks.length; i++) {
    const task = state.tasks[i]

    // we don't want to degrade completed tasks to active if they were once completed
    if (task.status === 'completed') {
      updatedTasks.push(task)
      continue
    }

    // Always set the task to completed if all tests are passing.
    // Unless there are no tests, in which case we're in a weird state,
    // but we shouldn't mark the whole thing as passing.
    if (
      // Check all tests on all tasks up to here have passed
      task.tests.length > 0 &&
      state.tasks
        .slice(0, i + 1)
        .every((t) => t.tests.every((test) => passingTests.has(test.slug)))
    ) {
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

  // Ensure that we have **some** completed tasks to mark this as true.
  // A lack of completed tasks should not mark the whole thing as completed.
  const areAllTasksCompleted =
    numberOfCompletedTasks > 0 && numberOfCompletedTasks === updatedTasks.length

  if (areAllTasksCompleted) {
    activeTaskIndex = undefined
  }

  return {
    updatedTasks,
    numberOfCompletedTasks,
    areAllTasksCompleted,
    activeTaskIndex,
  }
}
