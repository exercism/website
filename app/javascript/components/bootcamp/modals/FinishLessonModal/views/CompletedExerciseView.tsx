import React, { useContext } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { JikiscriptExercisePageContext } from '@/components/bootcamp/JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import { FinishLessonModalContext } from '../FinishLessonModalContextWrapper'

export function CompletedExerciseView() {
  const { t } = useAppTranslation('components/bootcamp/modals')
  const { nextExerciseData } = useContext(FinishLessonModalContext)
  const { links } = useContext(JikiscriptExercisePageContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.views.completedExerciseView.congratulations')}
      </h2>

      {nextExerciseData ? (
        <>
          <p className="text-18 leading-140 mb-8">
            {t('finishLessonModal.views.completedExerciseView.nextExerciseIs')}{' '}
            <strong className="font-semibold">{nextExerciseData.title}.</strong>
          </p>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.views.completedExerciseView.startItNowOrProjectsList'
            )}
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-secondary">
              {t('finishLessonModal.views.completedExerciseView.goToDashboard')}
            </a>
            <a
              href={nextExerciseData.solve_url}
              className="btn-l btn-primary flex-grow"
            >
              {t(
                'finishLessonModal.views.completedExerciseView.startNextExercise'
              )}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.views.completedExerciseView.wellDoneFinishedAllExercises'
            )}
          </p>

          <div className="flex flex-col items-stretch self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-primary">
              Go to dashboard
            </a>
          </div>
        </>
      )}
    </div>
  )
}
