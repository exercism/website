import React from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { TaskList } from './TaskList'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useTasks } from './useTasks'
import { useContext } from 'react'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'

export type TaskType = {
  status: 'completed' | 'active'
  uuid: string
  description: string
}

// =============== UNUSED COMPONENT ===============
function _Tasks() {
  const { tasks, numberOfTasks, numberOfCompletedTasks, areAllTasksCompleted } =
    useTaskStore()

  const { solution } = useContext(JikiscriptExercisePageContext)

  const { handleCompleteSolution } = useTasks()

  if (!tasks) return null
  return (
    <div data-ci="task-list" id="tasks">
      <div className="flex flex-row items-center justify-between">
        <h2>
          <span>Your</span> Tasks
        </h2>
        <div data-ci="task-completion-count">
          {numberOfCompletedTasks}/{numberOfTasks}
        </div>
      </div>
      <div className="list mb-[48px]">
        <TaskList tasks={tasks} />
      </div>

      {solution.status === 'in_progress' && (
        <>
          <button
            onClick={handleCompleteSolution}
            disabled={!areAllTasksCompleted}
            className={assembleClassNames(
              'bg-blue-500 text-white font-semibold text-lg px-8 py-2 rounded-md',
              areAllTasksCompleted ? '' : 'grayscale cursor-not-allowed'
            )}
          >
            Complete
          </button>
        </>
      )}
    </div>
  )
}

export const Tasks = wrapWithErrorBoundary(_Tasks)
