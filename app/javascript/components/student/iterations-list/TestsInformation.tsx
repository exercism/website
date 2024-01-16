import React from 'react'
import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
import { FetchingBoundary } from '../../FetchingBoundary'
import { ResultsZone } from '../../ResultsZone'
import { TestRunSummary } from '../../editor/TestRunSummary'
import { TestRun, TestRunner } from '../../editor/types'

const DEFAULT_ERROR = new Error('Unable to fetch test run')

type APIResponse = {
  testRun: TestRun
  testRunner: TestRunner
}

export const TestsInformation = ({
  request,
}: {
  request: Request
}): JSX.Element => {
  const {
    data: resolvedData,
    status,
    error,
    isFetching,
  } = usePaginatedRequestQuery<APIResponse>(
    ['test-run', request.endpoint],
    request
  )

  return (
    <ResultsZone isFetching={isFetching}>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {resolvedData ? (
          <TestRunSummary
            testRun={resolvedData.testRun}
            testRunner={resolvedData.testRunner}
            showSuccessBox={false}
          />
        ) : null}
      </FetchingBoundary>
    </ResultsZone>
  )
}
