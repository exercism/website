// i18n-key-prefix: views.completedLevelView
// i18n-namespace: components/bootcamp/CSSExercisePage/FinishLessonModal
import React, { useContext } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CompletedLevelView() {
  const { t } = useAppTranslation(
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { nextLevelIdx, completedLevelIdx, links } = useContext(
    FinishLessonModalContext
  )
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('views.completedLevelView.youveCompletedLevel', {
          completedLevelIdx,
        })}
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          {t('views.completedLevelView.thatsBigAchievement')}
        </strong>
      </p>
      {nextLevelIdx ? (
        <>
          <p className="text-18 leading-140 mb-20">
            {t('views.completedLevelView.youreNowOntoLevel', { nextLevelIdx })}
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a
              href={links.bootcampLevelUrl.replace(
                'idx',
                nextLevelIdx.toString()
              )}
              className="btn-l btn-primary flex-grow"
            >
              {t('views.completedLevelView.startLevel', { nextLevelIdx })}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            {t('views.completedLevelView.youveCompletedAllLevelsAvailable')}
          </p>

          <div className="flex flex-col items-stretch self-stretch">
            <a href={links.dashboardIndex} className="btn-l btn-primary">
              {t('views.completedLevelView.goToDashboard')}
            </a>
          </div>
        </>
      )}
    </div>
  )
}
