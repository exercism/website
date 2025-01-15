import React from 'react'
import { TestResultsButtons } from '../TestResultsView/TestResultsButtons'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { CheckScenariosButton } from './CheckScenariosButton'
import useTestStore from '../store/testStore'
import { PreviousTestResultsButtons } from '../PreviousTestResultsView/PreviousTestResultsButtons'
import { assembleClassNames } from '@/utils/assemble-classnames'

function _ControlButtons({ handleRunCode }: { handleRunCode: () => void }) {
  return (
    <div className="flex items-center gap-8 pb-12 overflow-auto shrink-0">
      {/* Run the tests with this button */}
      <CheckScenariosButton handleRunCode={handleRunCode} />
      {/* These buttons let you select a test/scenario that you want to inspect.  */}
      {/* Initial test/scenario preview buttons - no tests were ever run */}
      <PreviewTestButtons />
      {/* Just ran the tests */}
      <TestResultsButtons />
      {/* Previous test result buttons - previous means we had a submission of this exercise saved in the db */}
      <PreviousTestResultsButtons />
    </div>
  )
}

export const ControlButtons = wrapWithErrorBoundary(_ControlButtons)

function PreviewTestButtons() {
  const {
    testSuiteResult,
    previousTestSuiteResult,
    flatPreviewTaskTests,
    setInspectedPreviewTaskTest,
    inspectedPreviewTaskTest,
  } = useTestStore()
  if (testSuiteResult || previousTestSuiteResult) return null

  return (
    <div className="test-selector-buttons ">
      {flatPreviewTaskTests.map((taskTest, testIdx) => (
        <button
          key={testIdx}
          onClick={() => setInspectedPreviewTaskTest(taskTest)}
          className={assembleClassNames(
            'test-button idle',
            inspectedPreviewTaskTest.slug === taskTest.slug && 'selected'
          )}
        >
          {testIdx + 1}
        </button>
      ))}
    </div>
  )
}
