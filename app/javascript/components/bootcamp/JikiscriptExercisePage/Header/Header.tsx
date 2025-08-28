import React from 'react'
import useTaskStore from '../store/taskStore/taskStore'
import { FinishLessonModal } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModal'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { FinishLessonModalContextWrapper } from '@/components/bootcamp/modals/FinishLessonModal/FinishLessonModalContextWrapper'
import { useTasks } from '../Tasks/useTasks'
import { useContext } from 'react'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ResetButton } from './ResetButton'
import { CompletedBonusTasksModal } from '../../modals/CompletedBonusTasksModal/CompletedBonusTasksModal'
import { CustomFunctionsButton } from '../../CustomFunctionEditor/Header/CustomFunctionsButton'

function _Header() {
  const { areAllTasksCompleted } = useTaskStore()
  const { solution, links, exercise } = useContext(
    JikiscriptExercisePageContext
  )

  const {
    handleCompleteSolution,
    isFinishModalOpen,
    setIsFinishModalOpen,
    modalView,
    nextExerciseData,
    completedLevelIdx,
    nextLevelIdx,
    hasRuntimeErrors,
    isCompletedBonusTasksModalOpen,
    setIsCompletedBonusTasksModalOpen,
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
        {exercise.language === 'jikiscript' && <CustomFunctionsButton />}
        <ResetButton />

        {solution.status === 'in_progress' && (
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
        )}
        {areAllTasksCompleted && (
          <>
            <FinishLessonModalContextWrapper
              value={{
                isFinishLessonModalOpen: isFinishModalOpen,
                setIsFinishLessonModalOpen: setIsFinishModalOpen,
                isCompletedBonusTasksModalOpen,
                setIsCompletedBonusTasksModalOpen,
                completedLevelIdx,
                nextLevelIdx,
                handleCompleteSolution,
                modalView,
                nextExerciseData,
              }}
            >
              <FinishLessonModal />
              <CompletedBonusTasksModal />
            </FinishLessonModalContextWrapper>
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
