import React, { useContext } from 'react'
import { JikiscriptExercisePageContext } from '@/components/bootcamp/JikiscriptExercisePage/JikiscriptExercisePageContextWrapper'
import { FinishLessonModalContext } from '../FinishLessonModalContextWrapper'

export function CompletedExerciseView() {
  const { nextExerciseData } = useContext(FinishLessonModalContext)
  const { links } = useContext(JikiscriptExercisePageContext)
  return (
    <div>
      <h2 className="text-[25px] mb-12 font-semibold">Congratulations!</h2>

      {nextExerciseData ? (
        <>
          <p className="text-18 leading-140 mb-8">
            The next exercise is{' '}
            <strong className="font-semibold">{nextExerciseData.title}.</strong>
          </p>
          <p className="text-18 leading-140 mb-20">
            Do you want to start it now, or would you rather go back to the
            projects list?
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
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            Well done! You've finished all the exercises available to you right
            now.
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
