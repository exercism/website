import { processTasks } from '@/components/bootcamp/JikiscriptExercisePage/store/taskStore/processTasks'

const toTaskStore = (data) => {
  return {
    initializeTasks: () => {},
    markTaskAsCompleted: () => {},
    numberOfTasks: 0,
    areAllTasksCompleted: undefined,
    numberOfCompletedTasks: 0,
    activeTaskIndex: undefined,
    wasFinishLessonModalShown: false,
    setWasFinishLessonModalShown: () => {},
    setCurrentTaskIndex: () => {},

    ...data,
  }
}

test('no change if nothing changes', async () => {
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
      { slug: 'test1', textIndex: 1, status: 'pass' },
      { slug: 'test2', textIndex: 3, status: 'fail' },
    ],
    status: 'fail',
  }
  const actual = processTasks(toTaskStore(state), testResults)
  expect(actual.activeTaskIndex).toEqual(1)
  expect(actual.numberOfCompletedTasks).toEqual(1)
  expect(actual.areAllTasksCompleted).toBeFalse()
})
test('moves on if new test passes', async () => {
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
      {
        name: 'task3',
        tests: [{ slug: 'test3', status: 'fail' }],
        status: 'inactive',
      },
    ],
    numberOfCompletedTasks: 1,
    activeTaskIndex: 1,
  }
  const testResults = {
    tests: [
      { slug: 'test1', textIndex: 1, status: 'pass' },
      { slug: 'test2', textIndex: 2, status: 'pass' },
      { slug: 'test3', textIndex: 3, status: 'fail' },
    ],
    status: 'fail',
  }
  const actual = processTasks(toTaskStore(state), testResults)
  expect(actual.activeTaskIndex).toEqual(2)
  expect(actual.numberOfCompletedTasks).toEqual(2)
  expect(actual.areAllTasksCompleted).toBeFalse()
})
test('jumps if appropriate', async () => {
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
      {
        name: 'task3',
        tests: [{ slug: 'test3', status: 'fail' }],
        status: 'inactive',
      },
    ],
    numberOfCompletedTasks: 1,
    activeTaskIndex: 1,
  }
  const testResults = {
    tests: [
      { slug: 'test1', textIndex: 1, status: 'pass' },
      { slug: 'test2', textIndex: 3, status: 'pass' },
      { slug: 'test3', textIndex: 3, status: 'pass' },
    ],
    status: 'pass',
  }
  const actual = processTasks(toTaskStore(state), testResults)
  expect(actual.activeTaskIndex).toEqual(undefined)
  expect(actual.numberOfCompletedTasks).toEqual(3)
  expect(actual.areAllTasksCompleted).toBeTrue()
})

test("doesn't move on unless everything up to now passes", async () => {
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
  const actual = processTasks(toTaskStore(state), testResults)
  expect(actual.activeTaskIndex).toEqual(1)
  expect(actual.numberOfCompletedTasks).toEqual(1)
  expect(actual.areAllTasksCompleted).toBeFalse()
})
