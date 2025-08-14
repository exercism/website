import React, { useContext, useEffect, useMemo, useRef } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import Typewriter from 'typewriter-effect/dist/core'
import { type Options } from 'typewriter-effect'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { JikiscriptExercisePageContext } from '../../JikiscriptExercisePageContextWrapper'
import useTaskStore from '../../store/taskStore/taskStore'
import useTestStore from '../../store/testStore'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function _Instructions({
  exerciseTitle,
  exerciseInstructions,
  height = '100%',
}: {
  exerciseTitle: string
  exerciseInstructions: string
  height?: number | string
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/RHS'
  )
  const {
    activeTaskIndex,
    tasks,
    areAllTasksCompleted,
    bonusTasks,
    shouldShowBonusTasks,
  } = useTaskStore()
  const { remainingBonusTasksCount } = useTestStore()

  const { solution, exercise } = useContext(JikiscriptExercisePageContext)

  const typewriterRef = useRef<HTMLDivElement>(null)
  const isFirstRender = useRef(true)
  const currentTask = useMemo(
    () =>
      tasks !== null && activeTaskIndex !== undefined
        ? tasks[activeTaskIndex]
        : null,
    [activeTaskIndex, tasks]
  )

  const bonusTasksInstructions: string = useMemo(() => {
    if (!bonusTasks) return ''
    return bonusTasks.map((task) => task.instructionsHtml).join('')
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
    <div
      style={{ height }}
      className={assembleClassNames(
        'scenario-rhs c-prose c-prose-small',
        exercise.language
      )}
    >
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
          <h4>{t('instructions.instructions.bonusChallenges')}</h4>
          <div dangerouslySetInnerHTML={{ __html: bonusTasksInstructions }} />
        </>
      ) : areAllTasksCompleted || solution.passedBasicTests ? (
        <>
          <h4 className="mt-12">Congratulations!</h4>
          <p>
            {t(
              'instructions.instructions.youHaveSuccessfullyCompletedAllTheTasks'
            )}
          </p>
        </>
      ) : (
        <>
          <h4 className="mt-12">
            {t('instructions.instructions.task')}
            {activeTaskIndex !== undefined ? ` ${activeTaskIndex + 1}` : ''}:{' '}
            {currentTask?.name}
          </h4>
          {/* "inline" is required to keep the cursor on the same line */}
          <div ref={typewriterRef} />
        </>
      )}
    </div>
  )
}

export const Instructions = wrapWithErrorBoundary(_Instructions)
