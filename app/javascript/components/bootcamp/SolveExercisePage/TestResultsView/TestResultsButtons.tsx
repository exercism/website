import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'
import useEditorStore from '../store/editorStore'
import type { InformationWidgetData } from '../CodeMirror/extensions/end-line-information/line-information'
import { useShouldAnimate } from './useShouldAnimate'

const TRANSITION_DELAY = 0.2

export function TestResultsButtons() {
  const { testSuiteResult, setInspectedTestResult, inspectedTestResult } =
    useTestStore()
  const { setInformationWidgetData } = useEditorStore()

  const { shouldAnimate } = useShouldAnimate(testSuiteResult)

  if (!testSuiteResult) return null
  return (
    <div className="flex gap-x-4">
      {testSuiteResult.tests.map((test, idx) => {
        return (
          <button
            key={test.name + idx}
            onClick={() =>
              handleSetInspectedTestResult({
                testResult: test,
                setInspectedTestResult,
                setInformationWidgetData,
              })
            }
            style={{ transitionDelay: `${idx * TRANSITION_DELAY}s` }}
            className={assembleClassNames(
              'test-button',
              shouldAnimate ? test.status : 'idle',
              inspectedTestResult?.name === test.name
                ? 'outline outline-2 outline-slate-900'
                : ''
            )}
          >
            {idx + 1}
            <img
              src={`/${test.status}.svg`}
              width={18}
              height="auto"
              className="absolute top-0 right-0 translate-x-1/2 -translate-y-1/2 z-tooltip bg-white rounded-circle"
            />
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
