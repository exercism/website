import React from 'react'

import Modal from 'react-modal'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import { FinishLessonModalContext } from './FinishLessonModalContextWrapper'
import { useContext } from 'react'
import { SolveExercisePageContext } from '@/components/bootcamp/SolveExercisePage/SolveExercisePageContextWrapper'
import { NextExercise } from '../../SolveExercisePage/Tasks/completeSolution'
// import { playAudio } from "@/utils/play-audio";
// @ts-ignore
// import celebrationSound from "/task-completed-sound.aac";

Modal.setAppElement('body')
export function FinishLessonModal() {
  const { isOpen } = useContext(FinishLessonModalContext)
  // useEffect(() => {
  //   if (!isOpen) {
  //     return;
  //   }

  // TODO: Sort this out
  // playAudio(celebrationSound);
  // }, [isOpen]);

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
  const { modalView } = useContext(FinishLessonModalContext)
  const { nextLevelIdx, nextExerciseData } = useContext(
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

function InitialView() {
  const { handleCompleteSolution, setIsOpen } = useContext(
    FinishLessonModalContext
  )
  return (
    <>
      <LottieAnimation
        animationData={animation}
        className="confetti"
        style={{ height: '200px', width: '300px' }}
      />
      <h2 className="text-[25px] mb-12 font-semibold">Nice work!</h2>
      <p className="text-18 leading-140 mb-20">
        You can now mark this exercise as completed and move forward, or go back
        and carry on tweaking your code.
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button
          onClick={() => setIsOpen(false)}
          className="btn-l btn-secondary"
        >
          Tweak further
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          Complete Exercise
        </button>
      </div>
      <p className="mt-12 text-15 leading-140 text-textColor6 text-balance">
        (If you tweak further, you can complete the exercise using the button at
        the right when you're done)
      </p>
    </>
  )
}

function CompletedExerciseView({
  nextExerciseData,
}: {
  nextExerciseData: NextExercise
}) {
  const { links } = useContext(SolveExercisePageContext)
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
          Back to dashboard
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
  const { completedLevelIdx } = useContext(FinishLessonModalContext)
  const { links } = useContext(SolveExercisePageContext)
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
  const { completedLevelIdx } = useContext(FinishLessonModalContext)
  const { links } = useContext(SolveExercisePageContext)
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
          Back to dashboard
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
  const { links } = useContext(SolveExercisePageContext)

  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">Congratulations!</h2>
      <p className="text-18 leading-140 mb-20">
        Well done! You've finished all the exercises available to you right now.
      </p>

      <div className="flex flex-col items-stretch self-stretch">
        <a href={links.dashboardIndex} className="btn-l btn-primary">
          Back to dashboard
        </a>
      </div>
    </div>
  )
}
