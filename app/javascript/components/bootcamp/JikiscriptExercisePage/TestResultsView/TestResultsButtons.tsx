import React, { useCallback, useContext, useEffect, useMemo } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'
import useEditorStore from '../store/editorStore'
import type { InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { useShouldAnimate } from './useShouldAnimate'
import useTaskStore from '../store/taskStore/taskStore'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'

const TRANSITION_DELAY = 0.1

export function TestResultsButtons({ isBonus = false }) {
  const {
    testSuiteResult,
    bonusTestSuiteResult,
    setInspectedTestResult,
    inspectedTestResult,
  } = useTestStore()
  const { setInformationWidgetData, setReadonly: setIsEditorReadonly } =
    useEditorStore()
  const { shouldAutoplayAnimation } = useAnimationTimelineStore()
  const { shouldShowBonusTasks } = useTaskStore()

  const testResults = isBonus ? bonusTestSuiteResult : testSuiteResult
  const { shouldAnimate } = useShouldAnimate(testResults)
  const { isSpotlightActive } = useContext(JikiscriptExercisePageContext)

  useEffect(() => {
    setIsEditorReadonly(isSpotlightActive)
  }, [isSpotlightActive])

  const handleTestResultSelection = useCallback(
    (test: NewTestResult) => {
      if (!testResults) return
      if (isSpotlightActive) return

      if (shouldAutoplayAnimation) {
        const combinedResults = [
          ...(testSuiteResult?.tests || []),
          ...(bonusTestSuiteResult?.tests || []),
        ]
        manageTestAnimations(combinedResults, test.slug)
      }

      handleSetInspectedTestResult({
        testResult: test,
        setInspectedTestResult,
        setInformationWidgetData,
      })
    },
    [
      isSpotlightActive,
      testResults,
      bonusTestSuiteResult,
      testSuiteResult,
      shouldAutoplayAnimation,
      isBonus,
    ]
  )

  if (isBonus && !shouldShowBonusTasks) return null
  if (!testResults) return null

  return (
    <div
      className={
        isBonus ? 'test-selector-buttons bonus' : 'test-selector-buttons'
      }
    >
      {testResults.tests.map((test, idx) => (
        <button
          data-ci="test-selector-button"
          key={(test.slug || test.name) + idx}
          onClick={() => handleTestResultSelection(test)}
          style={{ transitionDelay: `${idx * TRANSITION_DELAY}s` }}
          className={assembleClassNames(
            'test-button',
            shouldAnimate ? test.status : 'idle',
            inspectedTestResult?.slug === test.slug ||
              inspectedTestResult?.name === test.name
              ? 'selected'
              : ''
          )}
        >
          {isBonus ? '★' : idx + 1}
        </button>
      ))}
    </div>
  )
}

export function handleSetInspectedTestResult({
  testResult,
  setInformationWidgetData,
  setInspectedTestResult,
}: {
  testResult: NewTestResult
  setInspectedTestResult: (test: NewTestResult) => void
  setInformationWidgetData: (data: InformationWidgetData) => void
}) {
  setInspectedTestResult(testResult)
  if (testResult.frames.length === 1) {
    const frame = testResult.frames[0]
    setInformationWidgetData({
      html: frame.description,
      line: frame.line,
      status: 'SUCCESS',
    })
  }
}

function manageTestAnimations(tests: NewTestResult[], slug: string) {
  tests.forEach((test) => {
    if (test.animationTimeline) {
      const timeline = test.animationTimeline
      if (
        test.slug === slug &&
        test.frames.every((frame) => frame.status === 'SUCCESS')
      ) {
        timeline.timeline.play()
      } else {
        timeline.pause()
      }
    }
  })
}
