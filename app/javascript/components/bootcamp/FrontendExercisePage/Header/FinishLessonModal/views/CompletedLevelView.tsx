import React, { useContext } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CompletedLevelView() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { nextLevelIdx, completedLevelIdx, links } = useContext(
    FinishLessonModalContext
  )
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.finishLessonModal.youveCompletedLevel', {
          completedLevelIdx,
        })}
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          {t(
            'finishLessonModal.finishLessonModal.congratulationsThatsABigAchievement'
          )}
        </strong>
      </p>
      {nextLevelIdx ? (
        <>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.finishLessonModal.youreNowOntoLevelANewChallengeRememberToWatchTheTeachingVideoInFullBeforeStartingTheExercises',
              { nextLevelIdx }
            )}
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a
              href={links.bootcampLevelUrl.replace(
                'idx',
                nextLevelIdx.toString()
              )}
              className="btn-l btn-primary flex-grow"
            >
              {t('finishLessonModal.finishLessonModal.startLevel', {
                nextLevelIdx,
              })}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.views.completedLevelView.youveCompletedAllTheLevelsAvailableToYouRightNowGreatJob'
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
