import React, { useContext } from 'react'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import { FinishLessonModalContext } from '../FinishLessonModal/FinishLessonModalContextWrapper'
import { JikiscriptExercisePageContext } from '../../JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'

export function CompletedBonusTasksView() {
  const { setIsCompletedBonusTasksModalOpen, handleCompleteSolution } =
    useContext(FinishLessonModalContext)
  const { links, solution } = useContext(JikiscriptExercisePageContext)

  return (
    <>
      <LottieAnimation
        animationData={animation}
        className="confetti"
        style={{ height: '200px', width: '300px' }}
      />
      <h2 className="text-[25px] mb-12 font-semibold">
        You aced the bonus tasks!
      </h2>

      <p className="text-18 leading-140 mb-20">
        You've completed the bonus tasks! You can mark this exercise as
        completed and move forward, or carry on tweaking your code.
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button
          onClick={() => setIsCompletedBonusTasksModalOpen(false)}
          className="btn-l btn-secondary"
        >
          Tweak further
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          {solution.status === 'completed' ? 'Continue' : 'Complete Exercise'}
        </button>
      </div>
      <p className="mt-12 text-15 leading-140 text-textColor6 text-balance">
        (If you tweak further, you can complete the exercise using the button at
        the right when you're done)
      </p>
    </>
  )
}
