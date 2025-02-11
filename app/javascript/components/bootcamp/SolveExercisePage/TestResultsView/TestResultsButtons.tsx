import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'
import useEditorStore from '../store/editorStore'
import type { InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { useShouldAnimate } from './useShouldAnimate'

const TRANSITION_DELAY = 0.1

export function TestResultsButtons() {
  const { testSuiteResult, setInspectedTestResult, inspectedTestResult } =
    useTestStore()
  const { setInformationWidgetData } = useEditorStore()

  const { shouldAnimate } = useShouldAnimate(testSuiteResult)

  if (!testSuiteResult) return null
  return (
    <div className="test-selector-buttons">
      {testSuiteResult.tests.map((test, idx) => {
        return (
          <button
            data-ci="test-selector-button"
            key={test.name + idx}
            onClick={() => {
              testSuiteResult.tests.forEach((test) => {
                if (test.animationTimeline) {
                  if (test.testIndex === idx) {
                    test.animationTimeline.play()
                  } else {
                    test.animationTimeline.pause()
                    test.animationTimeline.seek(0)
                  }
                }
              })
              handleSetInspectedTestResult({
                testResult: test,
                setInspectedTestResult,
                setInformationWidgetData,
              })
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
