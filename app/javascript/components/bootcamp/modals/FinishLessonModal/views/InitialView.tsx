import React from 'react'
import LottieAnimation from '@/components/bootcamp/common/LottieAnimation'
import animation from '@/../animations/finish-lesson-modal-top.json'
import useTaskStore from '@/components/bootcamp/JikiscriptExercisePage/store/taskStore/taskStore'
import useTestStore from '@/components/bootcamp/JikiscriptExercisePage/store/testStore'
import { useContext, useMemo, useCallback } from 'react'
import { FinishLessonModalContext } from '../FinishLessonModalContextWrapper'

export function InitialView() {
  const { handleCompleteSolution, setIsFinishLessonModalOpen: setIsOpen } =
    useContext(FinishLessonModalContext)

  const { bonusTestSuiteResult, remainingBonusTasksCount } = useTestStore()
  const { setShouldShowBonusTasks } = useTaskStore()

  const hasMoreBonusTasks = useMemo(() => {
    return bonusTestSuiteResult && remainingBonusTasksCount > 0
  }, [bonusTestSuiteResult, remainingBonusTasksCount])

  const bonusTaskInfoText = useMemo(() => {
    return bonusTestSuiteResult && bonusTestSuiteResult.tests.length > 1
      ? `There are ${
          bonusTestSuiteResult!.tests.length
        } bonus tasks on this exercise to complete. Do you want to go back to complete those now?`
      : `There is a bonus task on this exercise to complete. Do you want to go back to complete it now?`
  }, [bonusTestSuiteResult])

  const handleTweakFurther = useCallback(() => {
    setIsOpen(false)
    if (hasMoreBonusTasks) {
      setShouldShowBonusTasks(true)
    }
  }, [bonusTestSuiteResult, hasMoreBonusTasks])

  return (
    <>
      <LottieAnimation
        animationData={animation}
        className="confetti"
        style={{ height: '200px', width: '300px' }}
      />
      <h2 className="text-[25px] mb-12 font-semibold">Nice work!</h2>

      {hasMoreBonusTasks ? (
        <p className="text-18 leading-140 mb-8">{bonusTaskInfoText}</p>
      ) : (
        <p className="text-18 leading-140 mb-20">
          You can now mark this exercise as completed and move forward, or go
          back and carry on tweaking your code.
        </p>
      )}

      <div className="flex items-center gap-8 self-stretch">
        <button onClick={handleTweakFurther} className="btn-l btn-secondary">
          {hasMoreBonusTasks ? 'Tackle bonus tasks' : 'Tweak further'}
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
