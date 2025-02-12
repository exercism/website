import React, { useCallback, useContext, useEffect } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'
import useEditorStore from '../store/editorStore'
import type { InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { useShouldAnimate } from './useShouldAnimate'
import useAnimationTimelineStore from '../store/animationTimelineStore'
import { SolveExercisePageContext } from '../SolveExercisePageContextWrapper'

const TRANSITION_DELAY = 0.1

export function TestResultsButtons() {
  const { testSuiteResult, setInspectedTestResult, inspectedTestResult } =
    useTestStore()
  const { setInformationWidgetData, setReadonly: setIsEditorReadonly } =
    useEditorStore()
  const { shouldAutoplayAnimation } = useAnimationTimelineStore()
  const { shouldAnimate } = useShouldAnimate(testSuiteResult)

  const { isSpotlightActive } = useContext(SolveExercisePageContext)

  useEffect(() => {
    setIsEditorReadonly(isSpotlightActive)
  }, [isSpotlightActive])

  const handleTestResultSelection = useCallback(
    (test: NewTestResult, idx: number) => {
      if (!testSuiteResult) return
      // if we are showing spotlight, don't allow changing tests/scenarios
      if (isSpotlightActive) return

      if (shouldAutoplayAnimation) {
        manageTestAnimations(testSuiteResult, idx)
      }

      handleSetInspectedTestResult({
        testResult: test,
        setInspectedTestResult,
        setInformationWidgetData,
      })
    },
    [isSpotlightActive, testSuiteResult, shouldAutoplayAnimation]
  )

  if (!testSuiteResult) return null
  return (
    <div className="test-selector-buttons">
      {testSuiteResult.tests.map((test, idx) => {
        return (
          <button
            data-ci="test-selector-button"
            key={test.slug + idx}
            onClick={() => {
              handleTestResultSelection(test, idx)
            }}
            style={{ transitionDelay: `${idx * TRANSITION_DELAY}s` }}
            className={assembleClassNames(
              'test-button',
              shouldAnimate ? test.status : 'idle',
              inspectedTestResult?.slug === test.slug ? 'selected' : ''
            )}
          >
            {idx + 1}
          </button>
        )
      })}
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

function manageTestAnimations(
  testSuiteResult: TestSuiteResult<NewTestResult>,
  idx: number
) {
  testSuiteResult.tests.forEach((test) => {
    if (test.animationTimeline) {
      const timeline = test.animationTimeline
      if (test.testIndex === idx) {
        timeline.timeline.play()
      } else {
        timeline.pause()
      }
    }
  })
}
