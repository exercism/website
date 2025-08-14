import React, { useContext } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { JikiscriptExercisePageContext } from '../../../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import { FinishLessonModalContext } from '../FinishLessonModalContextWrapper'

export function CompletedLevelView() {
  const { t } = useAppTranslation('components/bootcamp/modals')
  const { nextLevelIdx, completedLevelIdx } = useContext(
    FinishLessonModalContext
  )
  const { links } = useContext(JikiscriptExercisePageContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.views.completedLevelView.completedLevel', {
          completedLevelIdx,
        })}
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          {t('finishLessonModal.views.completedLevelView.bigAchievement')}
        </strong>
      </p>
      {nextLevelIdx ? (
        <>
          <p className="text-18 leading-140 mb-20">
            {t('finishLessonModal.views.completedLevelView.nowOntoLevel', {
              nextLevelIdx,
            })}
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a
              href={links.bootcampLevelUrl.replace(
                'idx',
                nextLevelIdx.toString()
              )}
              className="btn-l btn-primary flex-grow"
            >
              {t('finishLessonModal.views.completedLevelView.startLevel', {
                nextLevelIdx,
              })}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            {t(
              'finishLessonModal.views.completedLevelView.completedAllLevelsAvailable'
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
