import React from 'react'
import Modal from 'react-modal'
import { FinishLessonModalContext } from './FinishLessonModalContext'
import { useContext } from 'react'
import { NextExercise } from '../../JikiscriptExercisePage/Tasks/completeSolution'
import { InitialView } from './views/InitialView'

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
  const { links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">Congratulations!</h2>

      <p className="text-18 leading-140 mb-8">
        The next exercise is{' '}
        <strong className="font-semibold">{nextExerciseData.title}.</strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        Do you want to start it now, or would you rather go back to the
        dashboard?
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-secondary">
          Go to dashboard
        </a>
        <a
          href={nextExerciseData.solve_url}
          className="btn-l btn-primary flex-grow"
        >
          Start Next Exercise
        </a>
      </div>
    </div>
  )
}

function CompletedLevelView({ nextLevelIdx }: { nextLevelIdx: number }) {
  const { completedLevelIdx, links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        You've completed level {completedLevelIdx}!
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          Congratulations! That's a big achievement 🎉
        </strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        You're now onto Level {nextLevelIdx} - a brand new challenge! Remember
        to watch the teaching video in full before starting the exercises.
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a
          href={links.bootcampLevelUrl.replace('idx', nextLevelIdx.toString())}
          className="btn-l btn-primary flex-grow"
        >
          Start Level {nextLevelIdx}
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
  const { completedLevelIdx, links } = useContext(FinishLessonModalContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">
        You've completed level {completedLevelIdx}!
      </h2>
      <p className="text-18 leading-140 mb-8">
        <strong className="font-semibold">
          Congratulations! That's a big achievement 🎉
        </strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        You've completed all the levels available to you right now, but you
        still have some exercises outstanding. The next exercise is{' '}
        <strong className="font-semibold">{nextExerciseData.title}.</strong>
      </p>
      <p className="text-18 leading-140 mb-20">
        Do you want to start it now, or would you rather go back to the projects
        list?
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-secondary">
          Go to dashboard
        </a>
        <a
          href={nextExerciseData.solve_url}
          className="btn-l btn-primary flex-grow"
        >
          Start Next Exercise
        </a>
      </div>
    </div>
  )
}

function CompletedEverythingView() {
  const { links } = useContext(FinishLessonModalContext)

  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">Congratulations!</h2>
      <p className="text-18 leading-140 mb-20">
        Well done! You've finished all the exercises available to you right now.
      </p>

      <div className="flex flex-col items-stretch self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-primary">
          Go to dashboard
        </a>
      </div>
    </div>
  )
}
