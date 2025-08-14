import React, { useContext, useCallback } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function InitialView() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { handleCompleteSolution, setIsFinishLessonModalOpen: setIsOpen } =
    useContext(FinishLessonModalContext)

  const handleTweakFurther = useCallback(() => {
    setIsOpen(false)
  }, [])

  return (
    <>
      <h2 className="text-[26px] mb-20 font-semibold text-textColor1">
        {t('finishLessonModal.views.initialView.readyToComplete')}
      </h2>

      <p className="text-18 leading-150 mb-20">
        {t(
          'finishLessonModal.views.initialView.inThisExerciseYouDecideWhenYoureHappyToFinishTheExerciseYourAimIsToHaveItLookAndFunctionTheSameAsTheExampleSolution'
        )}
      </p>
      <p className="text-18 leading-140 mb-20 font-medium">
        {t(
          'finishLessonModal.views.initialView.isYourSolutionReadyToMarkAsCompleted'
        )}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button onClick={handleTweakFurther} className="btn-l btn-secondary">
          {t('finishLessonModal.views.initialView.tweakFurther')}
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          {t('finishLessonModal.views.initialView.completeExercise')}
        </button>
      </div>
    </>
  )
}
