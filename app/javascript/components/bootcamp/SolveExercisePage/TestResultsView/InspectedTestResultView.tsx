import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import Scrubber from '../Scrubber/Scrubber'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import {
  useInspectedTestResultView,
  type ProcessedExpect,
} from './useInspectedTestResultView'
import { TestResultInfo } from './TestResultInfo'
import { PassMessage } from './PassMessage'

function _InspectedTestResultView() {
  const { result, viewContainerRef, firstFailingExpect, processedExpects } =
    useInspectedTestResultView()

  if (!result) return null

  return (
    <div
      className={assembleClassNames(
        'c-scenario',
        result.status === 'fail' ? 'fail' : 'pass'
      )}
    >
      <InspectedTestResultViewLHS
        // if tests pass, this will be first processed `expect`, otherwise first failing `expect`.
        firstExpect={firstFailingExpect}
        result={result}
      />

      <div ref={viewContainerRef} id="view-container" />
    </div>
  )
}

export const InspectedTestResultView = wrapWithErrorBoundary(
  _InspectedTestResultView
)

export function InspectedTestResultViewLHS({
  result,
  firstExpect,
}: {
  result: NewTestResult
  firstExpect: ProcessedExpect | null
}) {
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {result.name}
        </h3>

        <TestResultInfo result={result} firstExpect={firstExpect} />
        {result.status === 'pass' && <PassMessage testIdx={result.testIndex} />}
      </div>

      {result.frames && <Scrubber testResult={result} />}
    </div>
  )
}
