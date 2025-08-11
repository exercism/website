import React, { useContext } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import { FinishLessonModalContext } from '../FinishLessonModal/FinishLessonModalContextWrapper'
import { JikiscriptExercisePageContext } from '../../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'

export function CompletedBonusTasksView() {
  const { t } = useAppTranslation('components/bootcamp/modals')
  const { setIsCompletedBonusTasksModalOpen, handleCompleteSolution } =
    useContext(FinishLessonModalContext)
  const { links, solution } = useContext(JikiscriptExercisePageContext)

  return (
    <>
      <LottieAnimation
        animationData={animation}
        className="confetti"
        style={{ height: '200px', width: '300px' }}
      />
      <h2 className="text-[25px] mb-12 font-semibold">
        {t(
          'completedBonusTasksModal.completedBonusTasksView.youAcedTheBonusTasks'
        )}
      </h2>

      <p className="text-18 leading-140 mb-20">
        {t(
          'completedBonusTasksModal.completedBonusTasksView.youHaveCompletedBonusTasks'
        )}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button
          onClick={() => setIsCompletedBonusTasksModalOpen(false)}
          className="btn-l btn-secondary"
        >
          {t('completedBonusTasksModal.completedBonusTasksView.tweakFurther')}
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          {solution.status === 'completed'
            ? t('completedBonusTasksModal.completedBonusTasksView.continue')
            : t(
                'completedBonusTasksModal.completedBonusTasksView.completeExercise'
              )}
        </button>
      </div>
      <p className="mt-12 text-15 leading-140 text-textColor6 text-balance">
        {t('completedBonusTasksModal.completedBonusTasksView.tweakFurtherInfo')}
      </p>
    </>
  )
}
