import { createStoreWithMiddlewares } from '../utils'
import { getInitialTasks } from './getInitialTasks'
import { handleMarkTaskAsCompleted } from './handleMarkTaskAsCompleted'

const useTaskStore = createStoreWithMiddlewares<TaskStore>(
  (set) => ({
    tasks: null,
    numberOfTasks: 0,
    numberOfCompletedTasks: 0,
    wasFinishLessonModalShown: false,
    areAllTasksCompleted: undefined,
    activeTaskIndex: 0,
    setWasFinishLessonModalShown: (wasFinishLessonModalShown) => {
      set(
        { wasFinishLessonModalShown },
        false,
        'exercise/setWasFinishLessonModalShown'
      )
    },
    markTaskAsCompleted: (testResults) => {
      set(
        (state) => {
          return handleMarkTaskAsCompleted(state, testResults)
        },
        false,
        'exercise/markTaskAsCompleted'
      )
    },
    initializeTasks: (tasks, testResults) => {
      if (!tasks) {
        console.warn('tasks are missing in store')
        return
      }

      const taskData = getInitialTasks(tasks, testResults)
      set(
        {
          tasks: taskData.tasks as Task[],
          numberOfTasks: taskData.numberOfTasks,
          numberOfCompletedTasks: taskData.numberOfCompletedTasks,
          areAllTasksCompleted: taskData.areAllTasksCompleted,
          activeTaskIndex: taskData.activeTaskIndex,
        },
        false,
        'exercise/initializeTasks'
      )
    },
    setCurrentTaskIndex: (index) => {
      set({ activeTaskIndex: index }, false, 'exercise/setCurrentTaskIndex')
    },
  }),
  'TaskStore'
)

export default useTaskStore

export type TaskStore = {
  tasks: Task[] | null
  initializeTasks: (
    tasks: Omit<Task, 'status'>[] | null,
    testResults: TestSuiteResult<PreviousTestResult> | null
  ) => void
  markTaskAsCompleted: (testResults: TestSuiteResult<NewTestResult>) => void
  numberOfTasks: number
  areAllTasksCompleted: boolean | undefined
  numberOfCompletedTasks: number
  activeTaskIndex: number
  wasFinishLessonModalShown: boolean
  setWasFinishLessonModalShown: (wasFinishLessonModalShown: boolean) => void
  setCurrentTaskIndex: (index: number) => void
}
