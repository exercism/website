import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import Scrubber from '../Scrubber/Scrubber'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import {
  useInspectedTestResultView,
  type ProcessedExpect,
} from './useInspectedTestResultView'
import { FailInfo } from './FailInfo'
import { PassMessage } from './PassMessage'

function _InspectedTestResultView() {
  const { result, viewContainerRef, firstFailingExpect } =
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
        firstFailingExpect={firstFailingExpect}
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
  firstFailingExpect,
}: {
  result: NewTestResult
  firstFailingExpect: ProcessedExpect | null
}) {
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {result.name}
        </h3>

        {/*<div className="flex flex-col gap-4 p-8">
        <h2
          className={assembleClassNames(
            'text-18 font-semibold ',
            result.status === 'fail' ? 'mb-8' : ''
          )}
        >
          Scenario: {result.name} - {result.status}
        </h2>*/}

        {result.status === 'fail' ? (
          <FailInfo result={result} firstFailingExpect={firstFailingExpect} />
        ) : (
          <PassMessage testIdx={result.testIndex} />
        )}
      </div>
      <Scrubber testResult={result} />
    </div>
  )
}
