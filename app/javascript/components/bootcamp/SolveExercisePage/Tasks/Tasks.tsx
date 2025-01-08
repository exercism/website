import React from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import { FinishLessonModal } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModal'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { TaskList } from './TaskList'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FinishLessonModalContextWrapper } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModalContextWrapper'
import { useTasks } from './useTasks'
import { useContext } from 'react'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'

export type TaskType = {
  status: 'completed' | 'active'
  uuid: string
  description: string
}

function _Tasks() {
  const {
    tasks,
    numberOfTasks,
    numberOfCompletedTasks,
    areAllTasksCompleted,
    wasFinishLessonModalShown,
    setWasFinishLessonModalShown,
  } = useTaskStore()

  const { solution } = useContext(SolveExercisePageContext)

  const {
    handleCompleteSolution,
    isFinishModalOpen,
    setIsFinishModalOpen,
    modalView,
    nextExerciseData,
  } = useTasks({
    areAllTasksCompleted,
    wasFinishLessonModalShown,
    setWasFinishLessonModalShown,
  })

  if (!tasks) return null
  return (
    <div data-cy="task-list" id="tasks">
      <div className="flex flex-row items-center justify-between">
        <h2>
          <span>Your</span> Tasks
        </h2>
        <div data-cy="task-completion-count">
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
          {areAllTasksCompleted && (
            <FinishLessonModalContextWrapper
              value={{
                isOpen: isFinishModalOpen,
                setIsOpen: setIsFinishModalOpen,
                handleCompleteSolution,
                modalView,
                nextExerciseData,
              }}
            >
              <FinishLessonModal />
            </FinishLessonModalContextWrapper>
          )}
        </>
      )}
    </div>
  )
}

export const Tasks = wrapWithErrorBoundary(_Tasks)
