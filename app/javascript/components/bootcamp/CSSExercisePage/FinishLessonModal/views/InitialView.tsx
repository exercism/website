// i18n-key-prefix: views.initialView
// i18n-namespace: components/bootcamp/CSSExercisePage/FinishLessonModal
import React, { useContext, useCallback } from 'react'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import { FinishLessonModalContext } from '../FinishLessonModalContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function InitialView() {
  const { t } = useAppTranslation(
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { handleCompleteSolution, setIsFinishLessonModalOpen: setIsOpen } =
    useContext(FinishLessonModalContext)

  const handleTweakFurther = useCallback(() => {
    setIsOpen(false)
  }, [])

  return (
    <>
      <LottieAnimation
        animationData={animation}
        className="confetti"
        style={{ height: '200px', width: '300px' }}
      />
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('views.initialView.niceWork')}
      </h2>

      <p className="text-18 leading-140 mb-20">
        {t('views.initialView.markExerciseAsCompleted')}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button onClick={handleTweakFurther} className="btn-l btn-secondary">
          {t('views.initialView.tweakFurther')}
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          {t('views.initialView.completeExercise')}
        </button>
      </div>
      <p className="mt-12 text-15 leading-140 text-textColor6 text-balance">
        {t('views.initialView.tweakFurtherCompleteUsingButton')}
      </p>
    </>
  )
}
