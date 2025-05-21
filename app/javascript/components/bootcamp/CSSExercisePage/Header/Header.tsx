import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ResetButton } from './ResetButton'
import { CSSExercisePageContext } from '../CSSExercisePageContext'
import { useHandleCompletingSolution } from './useHandleCompletingSolution'
import { FinishLessonModal } from '../FinishLessonModal/FinishLessonModal'
import { FinishLessonModalContext } from '../FinishLessonModal/FinishLessonModalContext'
import { useCSSExercisePageStore } from '../store/cssExercisePageStore'

export type StudentCodeGetter = () => string | undefined

function _Header() {
  const { solution, links } = useContext(CSSExercisePageContext)

  const {
    assertionStatus,
    setIsFinishLessonModalOpen,
    isFinishLessonModalOpen,
  } = useCSSExercisePageStore()

  const {
    modalView,
    handleCompleteSolution,
    nextExerciseData,
    nextLevelIdx,
    completedLevelIdx,
  } = useHandleCompletingSolution({
    isFinishModalOpen: isFinishLessonModalOpen,
    setIsFinishModalOpen: setIsFinishLessonModalOpen,
    completeSolutionLink: links.completeSolution,
  })

  return (
    <div className="page-header justify-between">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>

      <div className="flex items-center gap-8">
        <ResetButton />
        {solution.status === 'in_progress' && (
          <button
            onClick={handleCompleteSolution}
            disabled={assertionStatus === 'fail'}
            className={assembleClassNames(
              'btn-primary btn-xxs',
              assertionStatus === 'fail' ? 'disabled cursor-not-allowed' : ''
            )}
          >
            Complete Exercise
          </button>
        )}
        {assertionStatus !== 'fail' && (
          <>
            <FinishLessonModalContext.Provider
              value={{
                isFinishLessonModalOpen,
                setIsFinishLessonModalOpen,
                completedLevelIdx,
                nextLevelIdx,
                handleCompleteSolution,
                modalView,
                nextExerciseData,
                links,
              }}
            >
              <FinishLessonModal />
            </FinishLessonModalContext.Provider>
          </>
        )}

        <a
          href={links.dashboardIndex}
          className={assembleClassNames('btn-secondary btn-xxs')}
        >
          Back
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)
