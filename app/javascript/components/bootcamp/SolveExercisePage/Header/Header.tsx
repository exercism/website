import React from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import { FinishLessonModal } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModal'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FinishLessonModalContextWrapper } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModalContextWrapper'
import { useTasks } from '../Tasks/useTasks'
import { useContext } from 'react'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ResetButton } from './ResetButton'

function _Header() {
  const { areAllTasksCompleted } = useTaskStore()

  const { solution, links } = useContext(SolveExercisePageContext)

  const {
    handleCompleteSolution,
    isFinishModalOpen,
    setIsFinishModalOpen,
    modalView,
    nextExerciseData,
    completedLevelIdx,
    nextLevelIdx,
    hasRuntimeErrors,
  } = useTasks()

  return (
    <div className="page-header">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>
      <div className="ml-auto flex items-center gap-8">
        <ResetButton />

        {solution.status === 'in_progress' && (
          <>
            <button
              onClick={handleCompleteSolution}
              disabled={!areAllTasksCompleted || hasRuntimeErrors}
              className={assembleClassNames(
                'btn-primary btn-xxs',
                areAllTasksCompleted ? '' : 'disabled cursor-not-allowed'
              )}
            >
              Complete Exercise
            </button>
            {areAllTasksCompleted && (
              <FinishLessonModalContextWrapper
                value={{
                  isOpen: isFinishModalOpen,
                  completedLevelIdx,
                  nextLevelIdx,
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
          href={links.dashboardIndex}
          className={assembleClassNames('btn-default btn-xxs')}
        >
          Back to Dashboard
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
