// i18n-key-prefix: views.completedExerciseView
// i18n-namespace: components/bootcamp/CSSExercisePage/FinishLessonModal
import React, { useContext } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CompletedExerciseView() {
  const { t } = useAppTranslation(
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { nextExerciseData, links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('views.completedExerciseView.congratulations')}
      </h2>

      {nextExerciseData ? (
        <>
          <p className="text-18 leading-140 mb-8">
            {t('views.completedExerciseView.nextExerciseIs')}
            <strong className="font-semibold">{nextExerciseData.title}.</strong>
          </p>
          <p className="text-18 leading-140 mb-20">
            {t('views.completedExerciseView.startItNowOrDashboard')}
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-secondary">
              {t('views.completedExerciseView.goToDashboard')}
            </a>
            <a
              href={nextExerciseData.solve_url}
              className="btn-l btn-primary flex-grow"
            >
              {t('views.completedExerciseView.startNextExercise')}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            {t('views.completedExerciseView.finishedAllExercisesAvailable')}
          </p>

          <div className="flex flex-col items-stretch self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-primary">
              {t('views.completedExerciseView.goToDashboard')}
            </a>
          </div>
        </>
      )}
    </div>
  )
}
