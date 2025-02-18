import React from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import useTaskStore from '../store/taskStore/taskStore'
import { useEffect, useMemo, useRef } from 'react'
import Typewriter from 'typewriter-effect/dist/core'
import { type Options } from 'typewriter-effect'
import { useLogger } from '@/hooks'
import { highlightAllAlways, useHighlighting } from '@/utils/highlight'
import { useContinuousHighlighting } from '@/hooks/use-syntax-highlighting'

export function _Instructions({
  exerciseTitle,
  exerciseInstructions,
}: {
  exerciseTitle: string
  exerciseInstructions: string
}): JSX.Element {
  const { activeTaskIndex, tasks, areAllTasksCompleted } = useTaskStore()

  const typewriterRef = useRef<HTMLDivElement>(null)
  const isFirstRender = useRef(true)
  const currentTask = useMemo(
    () =>
      tasks !== null && activeTaskIndex !== undefined
        ? tasks[activeTaskIndex]
        : null,
    [activeTaskIndex, tasks]
  )

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

  const highlightRef = useContinuousHighlighting<HTMLDivElement>()

  return (
    <div className="scenario-rhs c-prose c-prose-small">
      <h3>{exerciseTitle}</h3>

      <div
        ref={highlightRef}
        dangerouslySetInnerHTML={{
          __html: exerciseInstructions || '<p>Instructions are missing</p>',
        }}
      />

      {areAllTasksCompleted ? (
        <>
          <h4 className="mt-12">Congratulations!</h4>
          <p>You have successfully completed all the tasks!</p>
        </>
      ) : (
        <>
          <h4 className="mt-12">
            Task{activeTaskIndex !== undefined ? ` ${activeTaskIndex + 1}` : ''}
            : {currentTask?.name}
          </h4>
          {/* "inline" is required to keep the cursor on the same line */}
          <div ref={typewriterRef} />
        </>
      )}
    </div>
  )
}

export const Instructions = wrapWithErrorBoundary(_Instructions)
