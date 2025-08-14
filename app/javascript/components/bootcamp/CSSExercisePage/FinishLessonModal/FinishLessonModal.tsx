// i18n-key-prefix: finishLessonModal
// i18n-namespace: components/bootcamp/CSSExercisePage/FinishLessonModal
import React from 'react'
import Modal from 'react-modal'
import { FinishLessonModalContext } from './FinishLessonModalContext'
import { useContext } from 'react'
import { NextExercise } from '../../JikiscriptExercisePage/Tasks/completeSolution'
import { InitialView } from './views/InitialView'
import { useAppTranslation } from '@/i18n/useAppTranslation'

Modal.setAppElement('body')
export function FinishLessonModal() {
  const { t } = useAppTranslation(
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
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
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.congratulations')}
      </h2>

      <p className="text-18 leading-140 mb-8">
        {t('finishLessonModal.nextExerciseIs')}
        <strong className="font-semibold">{nextExerciseData.title}.</strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        {t('finishLessonModal.startItNowOrDashboard')}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-secondary">
          {t('finishLessonModal.goToDashboard')}
        </a>
        <a
          href={nextExerciseData.solve_url}
          className="btn-l btn-primary flex-grow"
        >
          {t('finishLessonModal.startNextExercise')}
        </a>
      </div>
    </div>
  )
}

function CompletedLevelView({ nextLevelIdx }: { nextLevelIdx: number }) {
  const { t } = useAppTranslation(
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { completedLevelIdx, links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.youveCompletedLevel', { completedLevelIdx })}
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          {t('finishLessonModal.thatsBigAchievement')}
        </strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        {t('finishLessonModal.youreNowOntoLevel', { nextLevelIdx })}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a
          href={links.bootcampLevelUrl.replace('idx', nextLevelIdx.toString())}
          className="btn-l btn-primary flex-grow"
        >
          {t('finishLessonModal.startLevel', { nextLevelIdx })}
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
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { completedLevelIdx, links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.youveCompletedLevel', { completedLevelIdx })}
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          {t('finishLessonModal.thatsBigAchievement')}
        </strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        {t('finishLessonModal.youveCompletedAllLevelsAvailable')}
        <strong className="font-semibold">{nextExerciseData.title}.</strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        {t('finishLessonModal.startItNowOrDashboard')}
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-secondary">
          {t('finishLessonModal.goToDashboard')}
        </a>
        <a
          href={nextExerciseData.solve_url}
          className="btn-l btn-primary flex-grow"
        >
          {t('finishLessonModal.startNextExercise')}
        </a>
      </div>
    </div>
  )
}

function CompletedEverythingView() {
  const { t } = useAppTranslation(
    'components/bootcamp/CSSExercisePage/FinishLessonModal'
  )
  const { links } = useContext(FinishLessonModalContext)

  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        {t('finishLessonModal.congratulations')}
      </h2>
      <p className="text-18 leading-140 mb-20">
        {t('finishLessonModal.finishedAllExercisesAvailable')}
      </p>

      <div className="flex flex-col items-stretch self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-primary">
          {t('finishLessonModal.goToDashboard')}
        </a>
      </div>
    </div>
  )
}
