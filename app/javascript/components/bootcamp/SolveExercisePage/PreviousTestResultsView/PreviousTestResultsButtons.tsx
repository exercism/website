import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import useTestStore from '../store/testStore'

const TRANSITION_DELAY = 0.1

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
              inspectedPreviousTestResult?.name === test.name ? 'selected' : ''
            )}
          >
            {idx + 1}
          </button>
        )
      })}
    </div>
  )
}
