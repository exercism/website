import React, { useContext } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CompletedExerciseView() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { nextExerciseData, links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.finishLessonModal.congratulations')}
      </h2>

      {nextExerciseData ? (
        <>
          <p className="text-18 leading-140 mb-8">
            {t('finishLessonModal.finishLessonModal.nextExerciseIs')}
            <strong className="font-semibold">{nextExerciseData.title}.</strong>
          </p>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.finishLessonModal.doYouWantToStartItNowOrWouldYouRatherGoBackToTheDashboard'
            )}
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-secondary">
              {t('finishLessonModal.finishLessonModal.goToDashboard')}
            </a>
            <a
              href={nextExerciseData.solve_url}
              className="btn-l btn-primary flex-grow"
            >
              {t('finishLessonModal.finishLessonModal.startNextExercise')}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.views.completedExerciseView.wellDoneYouveFinishedAllTheExercisesAvailableToYouRightNow'
            )}
          </p>

          <div className="flex flex-col items-stretch self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-primary">
              {t('finishLessonModal.finishLessonModal.goToDashboard')}
            </a>
          </div>
        </>
      )}
    </div>
  )
}
