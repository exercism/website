import { processTasks } from '@/components/bootcamp/SolveExercisePage/store/taskStore/processTasks'

test('switching completed/active', async () => {
  const state = {
    tasks: [
      {
        name: 'task1',
        tests: [{ slug: 'test1', status: 'pass' }],
        status: 'completed',
      },
      {
        name: 'task2',
        tests: [{ slug: 'test2', status: 'fail' }],
        status: 'active',
      },
    ],
    numberOfCompletedTasks: 1,
    activeTaskIndex: 1,
  }
  const testResults = {
    tests: [
      { slug: 'test1', textIndex: 1, status: 'fail' },
      { slug: 'test2', textIndex: 2, status: 'pass' },
    ],
    status: 'fail',
  }
  const actual = processTasks(state, testResults)
  expect(actual.activeTaskIndex).toEqual(1)
  expect(actual.numberOfCompletedTasks).toEqual(1)
  expect(actual.areAllTasksCompleted).toBeFalse()
})
