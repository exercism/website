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
      <h2 className="text-[25px] mb-12 font-semibold">👋 Hey!</h2>

      <p className="text-18 leading-140 mb-20">
        In this exercise, it's left up to you to decide when you've got your
        result to a standard you're happy with. Do you feel this exercise is
        ready for you to complete?
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
