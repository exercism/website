import React, { useContext } from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import Scrubber from '../Scrubber/Scrubber'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import {
  useInspectedTestResultView,
  type ProcessedExpect,
} from './useInspectedTestResultView'
import { TestResultInfo } from './TestResultInfo'
import { PassMessage } from './PassMessage'
import { JikiscriptExercisePageContext } from '../JikiscriptExercisePageContextWrapper'

function _InspectedTestResultView() {
  const { result, viewContainerRef, firstExpect } = useInspectedTestResultView()
  const { isSpotlightActive } = useContext(JikiscriptExercisePageContext)

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
        firstExpect={firstExpect}
        result={result}
      />

      <div
        className={assembleClassNames(isSpotlightActive && 'spotlight')}
        ref={viewContainerRef}
        id="view-container"
      />
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
  const { exercise } = useContext(JikiscriptExercisePageContext)

  return (
    <div data-ci="inspected-test-result-view" className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {result.name}
        </h3>

        {result.descriptionHtml && result.descriptionHtml.length > 0 && (
          <div className="description">
            <strong>Task: </strong>
            <span
              dangerouslySetInnerHTML={{
                __html: result.descriptionHtml,
              }}
            />
          </div>
        )}
        {result.status === 'pass' && <PassMessage testIdx={result.testIndex} />}
        <TestResultInfo result={result} firstExpect={firstExpect} />
      </div>

      {exercise.language === 'jikiscript' && result.frames && (
        <Scrubber
          animationTimeline={result.animationTimeline}
          frames={result.frames}
        />
      )}
    </div>
  )
}
