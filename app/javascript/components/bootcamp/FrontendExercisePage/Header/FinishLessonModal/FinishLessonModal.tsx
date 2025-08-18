import React from 'react'

import Modal from 'react-modal'
import { FinishLessonModalContext } from './FinishLessonModalContext'
import { useContext } from 'react'
import { InitialView } from './views/InitialView'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { NextExercise } from '@/components/bootcamp/JikiscriptExercisePage/Tasks/completeSolution'
import { Trans } from 'react-i18next'

Modal.setAppElement('body')
export function FinishLessonModal() {
  const { isFinishLessonModalOpen: isOpen } = useContext(
    FinishLessonModalContext
  )

  return (
    // @ts-ignore
    <Modal
      isOpen={isOpen}
      className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[540px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <Inner />
    </Modal>
  )
}

function Inner() {
  const { modalView, nextLevelIdx, nextExerciseData } = useContext(
    FinishLessonModalContext
  )
  switch (modalView) {
    case 'initial':
      return <InitialView />
    case 'completedExercise':
      if (nextExerciseData) {
        return <CompletedExerciseView nextExerciseData={nextExerciseData} />
      } else {
        return <CompletedEverythingView />
      }
    case 'completedLevel':
      if (nextLevelIdx) {
        return <CompletedLevelView nextLevelIdx={nextLevelIdx} />
      }

      if (nextExerciseData) {
        return <CompletedAllLevelsView nextExerciseData={nextExerciseData} />
      } else {
        return <CompletedEverythingView />
      }
  }
}

function CompletedExerciseView({
  nextExerciseData,
}: {
  nextExerciseData: NextExercise
}) {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.finishLessonModal.congratulations')}
      </h2>

      <p className="text-18 leading-140 mb-8">
        <Trans
          ns="components/bootcamp/FrontendExercisePage/Header"
          i18nKey="finishLessonModal.finishLessonModal.nextExerciseIs"
          values={{ exerciseTitle: nextExerciseData.title }}
          components={[<strong className="font-semibold" />]}
        />
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
    </div>
  )
}

function CompletedLevelView({ nextLevelIdx }: { nextLevelIdx: number }) {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { completedLevelIdx, links } = useContext(FinishLessonModalContext)
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
      <p className="text-18 leading-140 mb-20">
        {t(
          'finishLessonModal.finishLessonModal.youreNowOntoLevelANewChallengeRememberToWatchTheTeachingVideoInFullBeforeStartingTheExercises',
          { nextLevelIdx }
        )}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a
          href={links.bootcampLevelUrl.replace('idx', nextLevelIdx.toString())}
          className="btn-l btn-primary flex-grow"
        >
          {t('finishLessonModal.finishLessonModal.startLevel', {
            nextLevelIdx,
          })}
        </a>
      </div>
    </div>
  )
}

function CompletedAllLevelsView({
  nextExerciseData,
}: {
  nextExerciseData: NextExercise
}) {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { completedLevelIdx, links } = useContext(FinishLessonModalContext)
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
      <p className="text-18 leading-140 mb-20">
        {t(
          'finishLessonModal.finishLessonModal.youveCompletedAllTheLevelsAvailableToYouRightNowButYouStillHaveSomeExercisesOutstanding'
        )}
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
    </div>
  )
}

function CompletedEverythingView() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/Header'
  )
  const { links } = useContext(FinishLessonModalContext)

  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.finishLessonModal.congratulations')}
      </h2>
      <p className="text-18 leading-140 mb-20">
        {t(
          'finishLessonModal.finishLessonModal.wellDoneYouveFinishedAllTheExercisesAvailableToYouRightNow'
        )}
      </p>

      <div className="flex flex-col items-stretch self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-primary">
          {t('finishLessonModal.finishLessonModal.goToDashboard')}
        </a>
      </div>
    </div>
  )
}
