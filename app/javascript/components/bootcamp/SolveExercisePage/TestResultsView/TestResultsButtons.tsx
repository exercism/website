import React, { useCallback, useMemo } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'
import useEditorStore from '../store/editorStore'
import type { InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { useShouldAnimate } from './useShouldAnimate'
import useTaskStore from '../store/taskStore/taskStore'
import useAnimationTimelineStore from '../store/animationTimelineStore'

const TRANSITION_DELAY = 0.1

export function TestResultsButtons() {
  const { testSuiteResult, setInspectedTestResult, inspectedTestResult } =
    useTestStore()
  const { setInformationWidgetData } = useEditorStore()
  const { wasFinishLessonModalShown } = useTaskStore()
  const { shouldAutoplayAnimation } = useAnimationTimelineStore()
  const { shouldAnimate } = useShouldAnimate(testSuiteResult)

  const isSpotlightActive = useMemo(() => {
    if (!testSuiteResult) return false
    return !wasFinishLessonModalShown && testSuiteResult.status === 'pass'
  }, [wasFinishLessonModalShown, testSuiteResult?.status])

  const handleTestResultSelection = useCallback(
    (test: NewTestResult, idx: number) => {
      if (!testSuiteResult) return
      // if we are showing spotlight, don't allow changing tests/scenarios
      if (isSpotlightActive) return

      if (shouldAutoplayAnimation) {
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
            key={test.name + idx}
            onClick={() => {
              handleTestResultSelection(test, idx)
            }}
            style={{ transitionDelay: `${idx * TRANSITION_DELAY}s` }}
            className={assembleClassNames(
              'test-button',
              shouldAnimate ? test.status : 'idle',
              inspectedTestResult?.name === test.name ? 'selected' : ''
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
