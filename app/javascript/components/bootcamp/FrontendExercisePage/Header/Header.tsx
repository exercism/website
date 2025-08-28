import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ResetButton } from './ResetButton'
import { useHandleCompletingSolution } from './useHandleCompletingSolution'
import { FrontendExercisePageContext } from '../FrontendExercisePageContext'
import { useFrontendExercisePageStore } from '../store/frontendExercisePageStore'
import { FinishLessonModalContext } from './FinishLessonModal/FinishLessonModalContext'
import { FinishLessonModal } from './FinishLessonModal/FinishLessonModal'

export type StudentCodeGetter = () => string | undefined

function _Header() {
  const { links } = useContext(FrontendExercisePageContext)

  const { setIsFinishLessonModalOpen, isFinishLessonModalOpen } =
    useFrontendExercisePageStore()

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
        <button
          onClick={() => setIsFinishLessonModalOpen(true)}
          className={assembleClassNames('btn-primary btn-xxs')}
        >
          Complete Exercise
        </button>
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
