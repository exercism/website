import React from 'react'
import { TestRunSummary } from '../editor/TestRunSummary'
import { FetchingBoundary } from '../FetchingBoundary'
import { Modal, ModalProps } from './Modal'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { TestRun, TestRunner } from '../editor/types'
import { ResultsZone } from '../ResultsZone'

type APIResponse = {
  testRun: TestRun
  testRunner: TestRunner
}

const DEFAULT_ERROR = new Error('Unable to fetch test run')

export const TestRunModal = ({
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const {
    data: resolvedData,
    status,
    error,
    isFetching,
  } = usePaginatedRequestQuery<APIResponse>(['test-run', endpoint], {
    endpoint: endpoint,
    options: { enabled: props.open },
  })

  return (
    <Modal className="m-test-run" {...props}>
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
    </Modal>
  )
}
