import React from 'react'
import useTaskStore from './store/taskStore/taskStore'
import { FinishLessonModal } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModal'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FinishLessonModalContextWrapper } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModalContextWrapper'
import { useTasks } from './Tasks/useTasks'
import { useContext } from 'react'
import { SolveExercisePageContext } from './SolveExercisePageContextWrapper'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'

function _Header() {
  const {
    areAllTasksCompleted,
    wasFinishLessonModalShown,
    setWasFinishLessonModalShown,
  } = useTaskStore()

  const { solution, links } = useContext(SolveExercisePageContext)

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

  return (
    <div className="page-header">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>
      <div className="ml-auto flex items-center">
        {solution.status === 'in_progress' && (
          <>
            <button
              onClick={handleCompleteSolution}
              disabled={!areAllTasksCompleted}
              className={assembleClassNames(
                'btn-primary btn-xxs',
                areAllTasksCompleted ? '' : 'disabled cursor-not-allowed'
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

        <a
          href={links.projectsIndex}
          className={assembleClassNames('btn-secondary btn-xxs ml-8')}
        >
          Close
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
