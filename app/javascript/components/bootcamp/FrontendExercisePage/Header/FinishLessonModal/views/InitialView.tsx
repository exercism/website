import React, { useContext, useCallback } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContext'

export function InitialView() {
  const { handleCompleteSolution, setIsFinishLessonModalOpen: setIsOpen } =
    useContext(FinishLessonModalContext)

  const handleTweakFurther = useCallback(() => {
    setIsOpen(false)
  }, [])

  return (
    <>
      <h2 className="text-[26px] mb-20 font-semibold text-textColor1">
        Ready to Complete? 🎉
      </h2>

      <p className="text-18 leading-150 mb-20">
        In this exercise, you decide when you're happy to finish the exercise.
        Your aim is to have it look and function the same as the example
        solution.
      </p>
      <p className="text-18 leading-140 mb-20 font-medium">
        Is your solution ready to mark as completed?
      </p>

      <div className="flex items-center gap-8 self-stretch">
        <button onClick={handleTweakFurther} className="btn-l btn-secondary">
          Tweak further
        </button>
        <button
          onClick={handleCompleteSolution}
          className="btn-l btn-primary flex-grow"
        >
          Complete Exercise
        </button>
      </div>
    </>
  )
}
