import React from 'react'

import Modal from 'react-modal'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import { FinishLessonModalContext } from './FinishLessonModalContextWrapper'
import { useContext } from 'react'
import { SolveExercisePageContext } from '@/components/bootcamp/SolveExercisePage/SolveExercisePageContextWrapper'
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
      className="solve-exercise-page-react-modal-content flex flex-col items-center justify-center text-center max-w-[500px]"
      overlayClassName="solve-exercise-page-react-modal-overlay"
    >
      <Inner />
    </Modal>
  )
}

function Inner() {
  const { modalView } = useContext(FinishLessonModalContext)

  switch (modalView) {
    case 'initial':
      return <InitialView />
    case 'completedExercise':
      return <CompletedExerciseView />
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
      <p className="text-16 mb-10">
        You can now mark this exercise as complete, or go back and tweak your
        code further if you&apos;d like.
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button onClick={() => setIsOpen(false)} className="btn-l btn-standard">
          Code more
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          Complete
        </button>
      </div>
    </>
  )
}

function CompletedExerciseView() {
  const { nextExerciseData } = useContext(FinishLessonModalContext)
  const { links } = useContext(SolveExercisePageContext)
  return (
    <div className="[&_p]:text-16 [&_p]:mb-10">
      <h2 className="text-[25px] mb-12 font-semibold">Congratulations!</h2>

      {nextExerciseData ? (
        <>
          <p>The next exercise is {nextExerciseData.title}.</p>
          <p>
            Do you want to start it, or would you rather go back to the projects
            list?
          </p>
        </>
      ) : (
        <p>There are no exercises available at the moment.</p>
      )}

      <div className="flex items-center gap-8 self-stretch">
        {nextExerciseData && (
          <a
            href={links.projectsIndex + `/${nextExerciseData.project.slug}`}
            className="btn-l btn-primary flex-grow"
          >
            Continue
          </a>
        )}
        <a href={links.dashboardIndex} className="btn-l btn-standard">
          Back to dashboard
        </a>
      </div>
    </div>
  )
}
