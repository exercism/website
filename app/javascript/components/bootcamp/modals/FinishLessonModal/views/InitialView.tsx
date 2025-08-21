import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import useTaskStore from '@/components/bootcamp/JikiscriptExercisePage/store/taskStore/taskStore'
import useTestStore from '@/components/bootcamp/JikiscriptExercisePage/store/testStore'
import { useContext, useMemo, useCallback } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContextWrapper'

export function InitialView() {
  const { t } = useAppTranslation('components/bootcamp/modals')
  const { handleCompleteSolution, setIsFinishLessonModalOpen: setIsOpen } =
    useContext(FinishLessonModalContext)

  const { bonusTestSuiteResult, remainingBonusTasksCount } = useTestStore()
  const { setShouldShowBonusTasks } = useTaskStore()

  const hasMoreBonusTasks = useMemo(() => {
    return bonusTestSuiteResult && remainingBonusTasksCount > 0
  }, [bonusTestSuiteResult, remainingBonusTasksCount])

  const bonusTaskInfoText = useMemo(() => {
    return bonusTestSuiteResult && bonusTestSuiteResult.tests.length > 1
      ? t('finishLessonModal.views.initialView.thereAreBonusTasks', {
          bonusTaskCount: bonusTestSuiteResult!.tests.length,
        })
      : t('finishLessonModal.views.initialView.thereIsABonusTask')
  }, [bonusTestSuiteResult, t])

  const handleTweakFurther = useCallback(() => {
    setIsOpen(false)
    if (hasMoreBonusTasks) {
      setShouldShowBonusTasks(true)
    }
  }, [
    bonusTestSuiteResult,
    hasMoreBonusTasks,
    setIsOpen,
    setShouldShowBonusTasks,
  ])

  return (
    <>
      <LottieAnimation
        animationData={animation}
        className="confetti"
        style={{ height: '200px', width: '300px' }}
      />
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.views.initialView.niceWork')}
      </h2>

      {hasMoreBonusTasks ? (
        <p className="text-18 leading-140 mb-8">{bonusTaskInfoText}</p>
      ) : (
        <p className="text-18 leading-140 mb-20">
          {t('finishLessonModal.views.initialView.markAsCompleted')}
        </p>
      )}

      <div className="flex items-center gap-8 self-stretch">
        <button onClick={handleTweakFurther} className="btn-l btn-secondary">
          {hasMoreBonusTasks
            ? t('finishLessonModal.views.initialView.tackleBonusTasks')
            : t('finishLessonModal.views.initialView.tweakFurther')}
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          {t('finishLessonModal.views.initialView.completeExercise')}
        </button>
      </div>
      <p className="mt-12 text-15 leading-140 text-textColor6 text-balance">
        {t('finishLessonModal.views.initialView.tweakFurtherInfo')}
      </p>
    </>
  )
}
