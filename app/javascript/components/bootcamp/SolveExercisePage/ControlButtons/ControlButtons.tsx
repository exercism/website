import React from 'react'
import { TestResultsButtons } from '../TestResultsView/TestResultsButtons'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { CheckScenariosButton } from './CheckScenariosButton'
import useTestStore from '../store/testStore'
import { PreviousTestResultsButtons } from '../PreviousTestResultsView/PreviousTestResultsButtons'

function _ControlButtons({ handleRunCode }: { handleRunCode: () => void }) {
  return (
    <div className="flex px-12 items-center gap-8">
      <CheckScenariosButton handleRunCode={handleRunCode} />
      <TestResultsButtons />
      <IdleTestButton />
      <PreviousTestResultsButtons />
    </div>
  )
}

export const ControlButtons = wrapWithErrorBoundary(_ControlButtons)

function IdleTestButton() {
  const { testSuiteResult, previousTestSuiteResult } = useTestStore()
  if (testSuiteResult || previousTestSuiteResult) return null
  return (
    <div className="flex gap-x-4">
      <button className="test-button idle">1</button>
    </div>
  )
}
