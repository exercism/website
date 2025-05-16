import React, { useContext } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'

export function CompletedLevelView() {
  const { nextLevelIdx, completedLevelIdx, links } = useContext(
    FinishLessonModalContext
  )
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
      {nextLevelIdx ? (
        <>
          <p className="text-18 leading-140 mb-20">
            You're now onto Level {nextLevelIdx} - a brand new challenge!
            Remember to watch the teaching video in full before starting the
            exercises.
          </p>

          <div className="flex items-center gap-8 self-stretch">
            <a
              href={links.bootcampLevelUrl.replace(
                'idx',
                nextLevelIdx.toString()
              )}
              className="btn-l btn-primary flex-grow"
            >
              Start Level {nextLevelIdx}
            </a>
          </div>
        </>
      ) : (
        <>
          <p className="text-18 leading-140 mb-20">
            You've completed all the levels available to you right now. Great
            job!
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
