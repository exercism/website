import React from 'react'
import { TestResultsButtons } from '../TestResultsView/TestResultsButtons'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { CheckScenariosButton } from './CheckScenariosButton'
import useTestStore from '../store/testStore'
import { assembleClassNames } from '@/utils/assemble-classnames'

function _ControlButtons({ handleRunCode }: { handleRunCode: () => void }) {
  return (
    <div
      data-ci="control-buttons"
      className="flex items-center gap-8 pb-12 overflow-auto shrink-0"
    >
      {/* Run the tests with this button */}
      <CheckScenariosButton handleRunCode={handleRunCode} />
      {/* These buttons let you select a test/scenario that you want to inspect.  */}
      {/* Initial test/scenario preview buttons - no tests were ever run */}
      <PreviewTestButtons />
      {/* Just ran the tests */}
      <TestResultsButtons />
      <TestResultsButtons isBonus />
    </div>
  )
}

export const ControlButtons = wrapWithErrorBoundary(_ControlButtons)

function PreviewTestButtons() {
  const {
    testSuiteResult,
    flatPreviewTaskTests,
    setInspectedPreviewTaskTest,
    inspectedPreviewTaskTest,
  } = useTestStore()
  if (testSuiteResult) return null

  return (
    <div className="test-selector-buttons">
      {flatPreviewTaskTests.map((taskTest, testIdx) => (
        <button
          data-ci="preview-scenario-button"
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
