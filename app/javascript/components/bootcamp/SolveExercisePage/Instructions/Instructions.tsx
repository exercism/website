import React, { useContext } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import useTaskStore from '../store/taskStore/taskStore'
import { useEffect, useMemo, useRef } from 'react'
import Typewriter from 'typewriter-effect/dist/core'
import { type Options } from 'typewriter-effect'
import useTestStore from '../store/testStore'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'

export function _Instructions({
  exerciseTitle,
  exerciseInstructions,
}: {
  exerciseTitle: string
  exerciseInstructions: string
}): JSX.Element {
  const {
    activeTaskIndex,
    tasks,
    areAllTasksCompleted,
    bonusTasks,
    shouldShowBonusTasks,
  } = useTaskStore()
  const { remainingBonusTasksCount } = useTestStore()

  const { solution } = useContext(SolveExercisePageContext)

  const typewriterRef = useRef<HTMLDivElement>(null)
  const isFirstRender = useRef(true)
  const currentTask = useMemo(
    () => (tasks !== null ? tasks[activeTaskIndex] : null),
    [activeTaskIndex, tasks]
  )

  const bonusTasksList = useMemo(
    () =>
      bonusTasks?.flatMap((task) =>
        task.tests.map((test, index) => (
          <li
            key={test.slug + index}
            dangerouslySetInnerHTML={{
              __html: test.descriptionHtml || '<p>Instructions are missing</p>',
            }}
          />
        ))
      ) ?? [],
    [bonusTasks]
  )

  useEffect(() => {
    console.log('bonusTasks', bonusTasks)
  }, [bonusTasks])

  useEffect(() => {
    if (!typewriterRef.current || !currentTask) return

    // skip Typewriter on the first render
    if (isFirstRender.current) {
      typewriterRef.current.innerHTML = currentTask.instructionsHtml
      isFirstRender.current = false
    } else {
      // only type it out if a new task is the currentTask
      new Typewriter(typewriterRef.current, {
        autoStart: false,
        delay: 10,
        loop: false,
      } as Options)
        .typeString(currentTask.instructionsHtml)
        .callFunction(() => {
          // after typing is done, remove the typewriter wrapper - which includes a blinking cursor
          setTimeout(() => {
            if (typewriterRef.current) {
              typewriterRef.current.innerHTML = currentTask.instructionsHtml
            }
            // time we allow the cursor to blink idly before we remove it
          }, 700)
        })
        .start()
    }
  }, [currentTask])

  return (
    <div className="scenario-rhs c-prose c-prose-small">
      <h3>{exerciseTitle}</h3>

      <div
        dangerouslySetInnerHTML={{
          __html: exerciseInstructions || '<p>Instructions are missing</p>',
        }}
      />

      {shouldShowBonusTasks &&
      remainingBonusTasksCount > 0 &&
      !solution.passedBonusTests ? (
        <>
          <h4 id="h-bonus-challenges">Bonus Challenges</h4>
          <p>Want something to push you a little more?</p>
          <p>Here are two challenges:</p>
          <ul>{bonusTasksList} </ul>
        </>
      ) : areAllTasksCompleted || solution.passedBasicTests ? (
        <>
          <h4 className="mt-12">Congratulations!</h4>
          <p>You have successfully completed all the tasks!</p>
        </>
      ) : (
        <>
          <h4 className="mt-12">
            Task {activeTaskIndex + 1}: {currentTask?.name}
          </h4>
          {/* "inline" is required to keep the cursor on the same line */}
          <div ref={typewriterRef} />
        </>
      )}
    </div>
  )
}

export const Instructions = wrapWithErrorBoundary(_Instructions)
