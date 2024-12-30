import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'

const TRANSITION_DELAY = 0.2

export function PreviousTestResultsButtons() {
  const {
    previousTestSuiteResult,
    testSuiteResult,
    inspectedPreviousTestResult,
    setInspectedPreviousTestResult,
  } = useTestStore()

  if (!previousTestSuiteResult || testSuiteResult) return null
  return (
    <div className="flex gap-x-4">
      {previousTestSuiteResult.tests.map((test, idx) => {
        return (
          <button
            key={test.name + idx}
            onClick={() => {
              setInspectedPreviousTestResult(test)
            }}
            style={{ transitionDelay: `${idx * TRANSITION_DELAY}s` }}
            className={assembleClassNames(
              'test-button',
              test.status,
              inspectedPreviousTestResult?.name === test.name
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
